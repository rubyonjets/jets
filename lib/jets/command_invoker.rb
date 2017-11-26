module Jets
  class CommandInvoker
    # def self.invoke(full_namespace, args = [], **config)
    def self.start(given_args=ARGV, **config)
      # full_namespace, args = [], **config

      # command = full_namespace
      # args = args.dup
      # command = args.dup.shift
      args = args

      # puts "full_namespace #{full_namespace}"
      # puts "command #{command}"
      # puts "args #{args.inspect}"
      # puts "config #{config.inspect}"
      # puts ""

      puts "given_args #{given_args}"
      if given_args.first == "help"
        full_namespace = given_args[1]
      else
        full_namespace = given_args.first
      end
      puts "full_namespace #{full_namespace.inspect}"

      if full_namespace.nil?
        meth = nil
        namespace = nil
      elsif full_namespace.include?(':')
        words = full_namespace.split(':')
        meth = words.pop
        namespace = words.join(':')
      else
        meth = full_namespace
        namespace = nil
      end
      puts "namespace #{namespace.inspect}"

      thor_args = given_args.dup
      if given_args.first == "help"
        thor_args[1] = meth
      else
        thor_args[0] = meth
      end

      if namespace
        klass = "Jets::Commands::#{namespace.classify}".constantize
      else
        klass = Jets::CLI
      end
      klass.send(:dispatch, nil, thor_args, nil, config)

      # hard codes that work
      # Jets::Commands::Foo.send(:dispatch, :bar, [], nil, config)
      # Jets::Commands::Foo.send(:dispatch, nil, ["help", "bar"], nil, config)
    end
  end
end
