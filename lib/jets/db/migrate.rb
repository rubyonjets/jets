require "dynamodb_model"

# jets generate scaffold posts id:string title:string description:string
class Jets::Db::Migrate
  def initialize(path, options)
    @path = path
    @options = options
  end

  def run
    puts "Running database migrations"
    return if @options[:noop]
    migrate
  end

  def migrate
    require "#{Jets.root}#{@path}"
    migration_class = get_migration_class
    migration_class.new.up
  end

  def get_migration_class
    File.basename(@path, '.rb').classify.constantize
  end
end
