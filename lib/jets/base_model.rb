require "aws-sdk"
require "digest"

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
#   # Note, a race condition can exist using replace when there are several
#   # concurrent replace calls. Doing it this way for now because it's quick.
#   # TODO: implement post.update with db.update_item in a Ruby-ish way
#
module Jets
  class BaseModel
    attr_accessor :attrs
    def initialize(attrs={})
      @attrs = attrs
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

    def self.replace(attrs)
      # Automatically generate a random value for the parition key if one was
      # not provided.
      defaults = {
        "#{partition_key}": Digest::SHA1.hexdigest([Time.now, rand].join)
      }
      item = defaults.merge(attrs)

      # put_item full replaces the item
      resp = db.put_item(
        table_name: table_name,
        item: item
      )

      # The resp does not contain the attrs. So might as well return
      # the original item with the generated partition_key value
      item
    end

    def find(id)
      self.class.find(id)
    end

    def self.find(id)
      resp = db.get_item(
        table_name: table_name,
        key: {"#{partition_key}" => id}
      )
      resp.item # wraps the item
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

    def self.partition_key
      @partition_key || "id"
    end

    def self.table_name
      @table_name = self.name.pluralize.underscore
      [table_namespace, @table_name].join('-')
    end

    def self.table_namespace
      @table_namespace || Jets::Config.project_namespace
    end

    def db
      self.class.db
    end

    @@db = nil
    def self.db
      @@db ||= Aws::DynamoDB::Client.new
    end

  end
end
