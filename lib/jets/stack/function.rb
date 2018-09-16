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
      if source_file
        # Detect language from file extension
        ext = File.extname(source_file).sub(/^\./,'').to_sym
        lang_map[ext]
      else
        puts "WARN: Unable to find a source file for function. Looked at: #{search_expression}".colorize(:yellow)
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
      attributes = @template.values.first
      handler = attributes['Properties']['Handler']
      search_expression = handler.split('.')[0..-2].join('.') + '.*'
      search_expression.sub('handlers/shared/', "#{Jets.root}app/shared/")
    end

    # Relative path
    # app/shared/functions/kevin.py => handlers/shared/functions/kevin.py
    def handler_dest
      return unless source_file

      dest = source_file.sub(%r{.*/app/}, "handlers/")
      if lang == :ruby
        filename = dest.split('.').first
        filename + '.js' # change extension to .js because ruby uses a node shim
      else
        dest
      end
    end
  end
end