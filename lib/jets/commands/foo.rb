module Jets::Commands
  class Foo < Jets::Command
    desc "bar [options]", "bar desc"
    option :dry
    def bar
      puts "bar called"
      puts "options #{options.inspect}"
    end

    desc "bar [options]", "baz desc"
    def baz
      puts "baz called"
    end
  end
end
