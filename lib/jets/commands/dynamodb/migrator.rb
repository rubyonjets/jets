begin
  require "dynomite"
rescue LoadError # Commands::Base.eager_load
  nil
end

class Jets::Commands::Dynamodb::Migrator
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
    filename = File.basename(@path, '.rb')
    filename = filename.sub(/\d+[-_]/, '') # strip leading timestsamp
    filename.classify.constantize
  end
end
