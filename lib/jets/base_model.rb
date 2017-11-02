require "aws-sdk"
require "digest"

module Jets
  class BaseModel
    def create(item)
      base = {
        # TODO: allow specifying partition-key instead of assuming its id
        id: Digest::SHA1.hexdigest([Time.now, rand].join)
      }
      item = base.merge(item)

      resp = db.put_item(
        table_name: table_name,
        item: item
      )

      puts "create item: #{item.inspect}" if ENV['DEBUG']
      puts resp # provide full response
    end

    def find(id)
      resp = db.get_item(
        table_name: table_name,
        key: {id: id}
      )
      resp.item # wraps the item
    end

    @@db = nil
    def db
      @@db ||= Aws::DynamoDB::Client.new
    end

    def table_name
      self.class.table_name
    end

    def self.table_name
      @table_name = self.name.pluralize.underscore
      [table_namespace, @table_name].join('-')
    end

    def self.table_namespace
      @table_namespace || Jets::Config.project_namespace
    end
  end
end
