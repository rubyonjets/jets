class Jets::Commands::Foo < Jets::Command::Base
  desc "bar [options]", "bar desc"
  option :dry
  def bar
    puts "bar called"
    puts "options #{options.inspect}"
  end

  desc "baz [options]", "baz desc"
  def baz
    puts "baz called"
  end
end
