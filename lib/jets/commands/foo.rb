class Jets::Commands::Foo < Jets::Commands::Base
  desc "bar", "bar desc"
  option :dry
  def bar
    puts "bar called"
    puts "options #{options.inspect}"
  end

  desc "baz", "baz desc"
  def baz
    puts "baz called"
  end
end
