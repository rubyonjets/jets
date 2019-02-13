class Jets::Stack
  class Function
    extend Memoist

    attr_reader :template
    def initialize(template)
      @template = template
    end

    def meth
      attributes = @template.values.first
      handler = attributes['Properties']['Handler']
      handler.split('.').last
    end

    def lang
      return if internal?

      if source_file
        # Detect language from file extension
        ext = File.extname(source_file).sub(/^\./,'').to_sym
        lang_map[ext]
      else
        puts "WARN: Unable to find a source file for function. Looked at: #{search_expression}".color(:yellow)
      end
    end

    def lang_map
      {
        rb: :ruby,
        py: :python,
        js: :node,
      }
    end

    def source_file
      Dir.glob(search_expression).first
    end
    memoize :source_file

    def search_expression
      base_search_expression.sub('handlers/shared/', "#{Jets.root}/app/shared/")
    end

    def internal_search_expression
      internal = File.expand_path("../internal", File.dirname(__FILE__))
      base_search_expression.sub('handlers/shared/', "#{internal}/app/shared/")
    end

    def base_search_expression
      attributes = @template.values.first
      handler = attributes['Properties']['Handler']
      handler.split('.')[0..-2].join('.') + '.*' # search_expression
      # Example: handlers/shared/functions/jets/s3_bucket_config.*
    end

    # Internal flag is mainly used to disable WARN messages
    def internal?
      !!Dir.glob(internal_search_expression).first
    end

    # Relative path
    # app/shared/functions/kevin.py => handlers/shared/functions/kevin.py
    def handler_dest
      return unless source_file
      source_file.sub(%r{.*/app/}, "handlers/")
    end
  end
end