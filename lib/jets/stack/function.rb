class Jets::Stack
  class Function
    extend Memoist

    attr_reader :template
    def initialize(template)
      @template = template
    end

    def lang
      if source_file
        # Detect language from file extension
        ext = File.extname(source_file).sub(/^\./,'').to_sym
        lang_map[ext]
      else
        puts "WARN: Unable to find a source file for function. Looked at: #{path_expression}".colorize(:yellow)
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
      Dir.glob(path_expression).first
    end
    memoize :source_file

    def path_expression
      attributes = @template.values.first
      handler = attributes['Properties']['Handler']
      path_expression = handler.split('.')[0..-2].join('.') + '.*'
      path_expression.sub('handlers/shared', "#{Jets.root}app/shared/functions")
    end

    # Relative path
    # app/shared/functions/kevin.py => handlers/shared/functions/kevin.py
    def handler_dest
      source_file.sub(%r{.*/app/}, "handlers/")
    end
  end
end