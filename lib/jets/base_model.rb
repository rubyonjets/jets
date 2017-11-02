require "aws-sdk-dynamodb"
require "digest"
require "yaml"

# The modeling is ActiveRecord-ish but not exactly because DynamoDB is a
# different type of database.
#
# Examples:
#
#   post = Post.new
#   attributes = post.replace(title: "test title")
#   # attributes now contain a randomly generated partition_key
#   # Usually the partition_key is 'id'.
#
#   # You can set your own partition_key:
#   post = Post.new(id: "myid", title: "my title")
#   post.replace
#
#   # Note that the replace method replaces the entire item, so you
#   # need to merge the attributes if you want to keep the other attributes.
#   post = Post.find("myid")
#   post.attrs = post.attrs.deep_merge("desc": "my desc") # keeps title field
#   post.replace
#
#   # Convenience attrs() method does a deep_merge
#   post = Post.find("myid")
#   post.attrs("desc": "my desc") # <= does a deep_merge
#   post.replace
#
#   # Note, a race condition can exist using replace when there are several
#   # concurrent replace calls. Doing it this way for now because it's quick.
#   # TODO: implement post.update with db.update_item in a Ruby-ish way
#
module Jets
  class BaseModel
    attr_writer :attrs
    def initialize(attrs={})
      @attrs = attrs
    end

    # Defining our own reader so we can do a deep merge if user passes in attrs
    def attrs(attributes={})
      if attributes.empty?
        @attrs
      else
        @attrs.deep_merge!(attributes)
      end
    end

    # Not using method_missing to allow usage of dot notation and assign
    # @attrs because it might hide actual missing methods errors.
    # DynamoDB attrs can go many levels deep so it makes less make sense to
    # use to dot notation.

    # The method is named replace to clearly indicate that the item is
    # fully replaced.
    def replace
      self.class.replace(@attrs)
    end

    def find(id)
      self.class.find(id)
    end

    def table_name
      self.class.table_name
    end

    def partition_key
      self.class.partition_key
    end

    # Longer hand methods for completeness.
    # Internallly encourage the shorter attrs method.
    def attributes=(attributes)
      @attributes = attributes
    end

    def attributes
      @attributes
    end

    # If the total number of scanned items exceeds the maximum data set size limit of 1 MB, the scan stops and results are returned to the user as a LastEvaluatedKey value to continue the scan in a subsequent operation.

    # aws dynamodb get-item \
    #     --table-name ProductCatalog \
    #     --key file://key.json \
    #     --projection-expression "Description, RelatedItems[0], ProductReviews.FiveStar"
    #
    # `key.json`:
    # {
    #     "Id": { "N": "123" }
    # }

    def self.scan(params={})
      # Jets.logger.info("Should not use scan for production. It's slow and expensive. You should create either a LSI or GSI and use query the index instead. Current environment: #{Jets.env}.")

      params = {
        expression_attribute_names: {
          "T" => "title",
          "D" => "desc",
        },
        expression_attribute_values: {
          ":a" => {
            s: "my title",
          },
        },
        filter_expression: "title = :a",
        projection_expression: "#T, #D",
        table_name: table_name,
      }

      params = {
        table_name: table_name,
        projection_expression: "title",
      }

      params = {
        table_name: table_name,
        expression_attribute_names: {"#t"=>"title", "#d"=>"desc"},
        projection_expression: "#t, #d",
      }

      params = {
        table_name: table_name,
        # desc is a keyword
        # since we can run into keywords we should always map attribute names
        # and values
        expression_attribute_values: {
          ":desc" => "my desc"
        },
        expression_attribute_names: {"#desc"=>"desc"},
        filter_expression: "#desc = :desc",
      }

      params = {
        table_name: table_name,
        filter_expression: "updated_at between :start_time and :end_time",
        expression_attribute_values: {
          ":start_time" => "2010-01-01T00:00:00",
          ":end_time" => "2020-01-01T00:00:00"
        }
      }

      params = {
        table_name: table_name,
        # projection_expression: "#t, #d",
        expression_attribute_names: {"#updated_at"=>"updated_at"},
        filter_expression: "#updated_at between :start_time and :end_time",
        expression_attribute_values: {
          ":start_time" => "2010-01-01T00:00:00",
          ":end_time" => "2020-01-01T00:00:00"
        }
      }

      Jets.logger.info("BaseModel Jets.env #{Jets.env.inspect}")
      Jets.logger.info("BaseModel params #{params.inspect}")

      # AWS Docs examples: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStarted.Ruby.04.html
      resp = db.scan(params)
    end

    def self.replace(attrs)
      # Automatically adds some attributes:
      #   partition key unique id
      #   created_at and updated_at timestamps. Timestamp format from AWS docs: http://amzn.to/2z98Bdc
      defaults = {
        "#{partition_key}" => Digest::SHA1.hexdigest([Time.now, rand].join)
      }
      item = defaults.merge(attrs)
      item["created_at"] ||= Time.now.utc.strftime('%Y-%m-%dT%TZ')
      item["updated_at"] = Time.now.utc.strftime('%Y-%m-%dT%TZ')

      # put_item full replaces the item
      resp = db.put_item(
        table_name: table_name,
        item: item
      )

      # The resp does not contain the attrs. So might as well return
      # the original item with the generated partition_key value
      item
    end

    def self.find(id)
      resp = db.get_item(
        table_name: table_name,
        key: {"#{partition_key}" => id}
      )
      attributes = resp.item # unwraps the item's attributes
      Post.new(attributes) if attributes
    end

    def self.partition_key
      @partition_key || "id"
    end

    def self.table_name
      @table_name = self.name.pluralize.underscore
      [table_namespace, @table_name].join('-')
    end

    @table_namespace = nil
    def self.table_namespace
      return @table_namespace if @table_namespace

      config = YAML.load_file("#{Jets.root}config/database.yml")[Jets.env]
      @table_namespace = config['table_namespace'] || Jets::Config.project_namespace
    end

    # TODO: if dynamodb-local is not available print message to use with instructions that is was not found and how to install it
    #
    # For normal production mode it is fine to leave the endpoint as nil
    # The Aws::DynamoDB::Client is smart enough to figure out the endpoint.
    # TODO: If in production mode and user has accidentally configured the endpoint, warn the user.
    def db
      self.class.db
    end

    @@db = nil
    def self.db
      return @@db if @@db

      config = YAML.load_file("#{Jets.root}config/database.yml") || {}
      endpoint = config['endpoint']
      Aws.config.update(endpoint: endpoint) if endpoint

      @@db ||= Aws::DynamoDB::Client.new
    end

  end
end
