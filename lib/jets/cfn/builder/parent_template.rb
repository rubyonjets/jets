require 'erb'

class Jets::Cfn::Builder
  class ParentTemplate
    include Helpers
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      puts "Building parent template"

      add_minimal_resources
      add_child_resources unless @options[:stack_type] == 'minimal'
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.parent_template_path
    end

    def add_minimal_resources
      path = File.expand_path("../templates/minimal-stack.yml", __FILE__)
      template = IO.read(path)

      # variables for minimal-stack.yml
      @policy_name = "lamdba-#{Jets::Config.project_namespace}-policy"
      @role_name = "lamdba-#{Jets::Config.project_namespace}-role"
      rendered_result = erb_result(path, template)
      minimal_template = YAML.load(rendered_result)

      # minimal_template = YAML.load(IO.read(path))
      @template.deep_merge!(minimal_template)
    end

    def add_child_resources
      expression = "#{Jets::Config.project_namespace}-*"
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        map = ChildMapper.new(path, @options[:s3_bucket])
        # map.logical_id - PostsController
        parameters = {}
        parameters = map.parameters unless shared_stack?(path)
        add_resource(map.logical_id, "AWS::CloudFormation::Stack",
          TemplateURL: map.template_url,
          Parameters: parameters,
        )
      end
    end

    def shared_stacks
      %w[api-gateway]
    end

    def shared_stack?(path)
      !!shared_stacks.find { |p| path.include?(p) }
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