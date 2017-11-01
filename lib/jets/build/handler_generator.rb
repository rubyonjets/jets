require "fileutils"
require "erb"

# Example:
#
# Jets::Build::HandlerGenerator.new(
#   "PostsController",
#   :create, :update
# )
class Jets::Build
  class HandlerGenerator
    def initialize(path)
      @path = path
    end

    def generate
      # find_deducer_class exames: ControllerDeducer or JobDeducer
      deducer_class = find_deducer_class
      deducer = deducer_class.new(@path)

      js_path = "#{Jets.root}#{deducer.js_path}"
      FileUtils.mkdir_p(File.dirname(js_path))

      template_path = File.expand_path('../node-shim.js', __FILE__)
      template = IO.read(template_path)

      @deducer = deducer # Required ERB variablefor node-shim.js template
      result = erb_result(template_path, template)

      IO.write(js_path, result)
    end

    # base on the path a different deducer will be used
    def find_deducer_class
      # process_class example: Jets::Build::Deducer::ControllerDeducer
      process_class = @path.split('/')[1].classify # Controller or Job
      "Jets::Build::Deducer::#{process_class}Deducer".constantize
    end

    def erb_result(path, template)
      begin
        ERB.new(template, nil, "-").result(binding)
      rescue Exception => e
        puts e
        puts e.backtrace if ENV['DEBUG']

        # how to know where ERB stopped? - https://www.ruby-forum.com/topic/182051
        # syntax errors have the (erb):xxx info in e.message
        # undefined variables have (erb):xxx info in e.backtrac
        error_info = e.message.split("\n").grep(/\(erb\)/)[0]
        error_info ||= e.backtrace.grep(/\(erb\)/)[0]
        raise unless error_info # unable to find the (erb):xxx: error line
        line = error_info.split(':')[1].to_i
        puts "Error evaluating ERB template on line #{line.to_s.colorize(:red)} of: #{path.sub(/^\.\//, '').colorize(:green)}"

        template_lines = template.split("\n")
        context = 5 # lines of context
        top, bottom = [line-context-1, 0].max, line+context-1
        spacing = template_lines.size.to_s.size
        template_lines[top..bottom].each_with_index do |line_content, index|
          line_number = top+index+1
          if line_number == line
            printf("%#{spacing}d %s\n".colorize(:red), line_number, line_content)
          else
            printf("%#{spacing}d %s\n", line_number, line_content)
          end
        end
        exit 1 unless ENV['TEST']
      end
    end
  end
end
