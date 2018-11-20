module Jets::Middleware
  class Layer
    attr_reader :args, :block, :klass

    def initialize(klass, args, block)
      @klass = klass
      @args  = args
      @block = block
    end

    def name; klass.name; end

    def ==(middleware)
      case middleware
      when Layer
        klass == middleware.klass
      when Class
        klass == middleware
      end
    end

    def inspect
      if klass.is_a?(Class)
        klass.to_s
      else
        klass.class.to_s
      end
    end

    def build(app)
      klass.new(app, *args, &block)
    end
  end
end
