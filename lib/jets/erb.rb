require 'erb'

# Renders Erb and provide better backtrace where there's an error
#
# Usage:
#
#   result = Jets::Erb.result(path, key1: "val1", key2: "val2")
#
class Jets::Erb
  class << self
    def result(path, variables={})
      set_template_variables(variables)
      template = IO.read(path)
      begin
        ERB.new(template, nil, "-").result(binding)
      rescue Exception => e
        puts e
        puts e.backtrace if ENV['JETS_DEBUG']

        # how to know where ERB stopped? - https://www.ruby-forum.com/topic/182051
        # syntax errors have the (erb):xxx info in e.message
        # undefined variables have (erb):xxx info in e.backtrac
        error_info = e.message.split("\n").grep(/\(erb\)/)[0]
        error_info ||= e.backtrace.grep(/\(erb\)/)[0]
        raise unless error_info # unable to find the (erb):xxx: error line
        line = error_info.split(':')[1].to_i
        puts "Error evaluating ERB template on line #{line.to_s.color(:red)} of: #{path.sub(/^\.\//, '').color(:green)}"

        template_lines = template.split("\n")
        context = 5 # lines of context
        top, bottom = [line-context-1, 0].max, line+context-1
        spacing = template_lines.size.to_s.size
        template_lines[top..bottom].each_with_index do |line_content, index|
          line_number = top+index+1
          if line_number == line
            printf("%#{spacing}d %s\n".color(:red), line_number, line_content)
          else
            printf("%#{spacing}d %s\n", line_number, line_content)
          end
        end
        exit 1 unless Jets.env.test?
      end
    end

    def set_template_variables(variables)
      variables.each do |key, value|
        instance_variable_set(:"@#{key}", value)
      end
    end
  end
end
