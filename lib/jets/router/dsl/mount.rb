module Jets::Router::Dsl
  module Mount
    # support these notations:
    #   mount Blorgh::Engine, at: "/blog"
    #   mount sprockets_env => "/assets"
    #   mount sprockets_env => "/assets", internal: true
    def mount(*args)
      options = args.extract_options!

      if args.empty?
        mount_option = options.find { |k,v| !k.is_a?(String) && !v.is_a?(Symbol) }
        mount_class, at = mount_option[0], mount_option[1]
      else
        mount_class = args.first
        at = options[:at]
      end

      at = "/#{at}" unless at.starts_with?("/")
      mount_class_at(mount_class, options.merge(at: at))
    end

    # The mounted class must be a Rack compatiable class
    def mount_class_at(klass, options={})
      if klass.is_a?(Class) && klass < Jets::Engine
        mount_engine(klass, options)
      else
        # Handles mount like Sprockets::Environment.new
        at = options.delete(:at)
        at = at[1..-1] if at.starts_with?('/') # be more forgiving if / accidentally included
        at_wildcard = at.blank? ? "*path" : "#{at}/*path"
        options.merge!(to: "jets/mount#call", mount_class: klass)

        any at, options
        any at_wildcard, options
      end
    end

    mattr_accessor :mounted_engines
    self.mounted_engines = {}
    def mount_engine(klass, options={})
      at = options.delete(:at)
      options.merge!(engine: klass, path: at)
      create_route(options)
      @@mounted_engines[at] = klass
    end
  end
end
