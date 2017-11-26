require "thor"
require "byebug"

class Jets::Command
  class << self
    def start(given_args=ARGV, **config)
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

      # puts "given_args #{given_args}"
      if given_args.first == "help"
        full_namespace = given_args[1]
      else
        full_namespace = given_args.first
      end
      # puts "full_namespace #{full_namespace.inspect}"

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
      # puts "namespace #{namespace.inspect}"

      thor_args = given_args.dup
      if given_args.first == "help"
        thor_args[1] = meth
      else
        thor_args[0] = meth
      end

      if namespace
        klass = "Jets::Commands::#{namespace.classify}".constantize
        klass.send(:dispatch, nil, thor_args, nil, config)
      else
        # klass = Jets::Command::Base
        top_level_help
      end

      # hard codes that work
      # Jets::Commands::Foo.send(:dispatch, :bar, [], nil, config)
      # Jets::Commands::Foo.send(:dispatch, nil, ["help", "bar"], nil, config)
    end

    def top_level_help
      # puts Jets::Commands::Foo.help(Thor::Shell::Basic.new)

      klass = Jets::Commands::Foo
      list = klass.printable_commands(true, false)
      # pp list
      namespace = namespace_from_class(klass)
      list.map! {|array| array[0].sub!("jets ", "jets #{namespace}:") ; array }

      shell = Thor::Shell::Basic.new
      shell.say "Commands:"
      shell.print_table(list, :indent => 2, :truncate => true)
    end

    def namespace_from_class(klass)
      klass.to_s.sub('Jets::Commands::', '').underscore.gsub('_',':')
    end
  end
end
