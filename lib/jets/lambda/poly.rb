module Jets::Lambda::Poly
  extend ActiveSupport::Concern

  included do
    class << self
      def defpoly(lang, meth)
        register_task(meth, lang)
      end
      
      puts "self outside #{self.inspect}"
      def default_handler(*args)
        @default_handler ||= {
          python: :handle,
          node: :handle,
        }
  
        # getter
        return @default_handler if args.empty?

        # setter
        lang, handler = args[0..1]
        puts "self #{self.inspect}"
        puts "@default_handler #{@default_handler.inspect}"
        @default_handler[lang.to_sym] = handler
      end
    end
  end
end
