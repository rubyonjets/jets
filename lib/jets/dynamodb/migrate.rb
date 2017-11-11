require "dynamodb_model"

# jets generate scaffold posts id:string title:string description:string
class Jets::Dynamodb::Migrate
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
    path = "#{Jets.root}#{@path}"
    unless File.exist?(path)
      puts "Unable to find the migration file: #{path}"
      exit 1
    end

    require path
    migration_class = get_migration_class
    migration_class.new.up
  end

  def get_migration_class
    File.basename(@path, '.rb').classify.constantize
  end
end
