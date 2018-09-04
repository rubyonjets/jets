# The class including this module should implement these methods:
#
#   * compose
#   * template_path
class Jets::Cfn::TemplateBuilders
  module Interface
    extend Memoist

    def build
      # Do not bother building
      # or writing the template unless there are functions defined
      return if @app_klass && !@app_klass.build?

      compose # must be implemented by subclass
      write
    end

    def write
      FileUtils.mkdir_p(File.dirname(template_path))
      IO.write(template_path, text)
    end

    def template
      # need the to_hash or the YAML dump has
      #  !ruby/hash:ActiveSupport::HashWithIndifferentAccess
      @template.to_hash
    end

    def text
      text = YAML.dump(template)
      post_process_template(text)
    end

    # post process the text so that
    # "!Ref IamRole" => !Ref IamRole
    # We strip the surrounding quotes
    def post_process_template(text)
      results = text.split("\n").map do |line|
        if line.include?(': "!') # IE: IamRole: "!Ref IamRole",
           # IamRole: "!Ref IamRole" => IamRole: !Ref IamRole
          line.sub(/: "(.*)"/, ': \1')
        elsif line.include?('- "!') # IE: - "!GetAtt Foo.Arn"
           # IamRole: - "!GetAtt Foo.Arn" => - !GetAtt Foo.Arn
          line.sub(/- "(.*)"/, '- \1')
        else
          line
        end
      end
      results.join("\n") + "\n"
    end

    # add_resource handles an options Hash with both only Properties
    # and also one with a nested Properties.

    # Example:
    #
    # Simple options with properties only:
    # add_resource("MyId", "AWS::CloudFormationStack",
    #   TemplateURL: "template_url",
    #   Parameters: {},
    # )
    #
    # More complicated options:
    # add_resource("MyId", "AWS::ApiGateway::RestApi",
    #   Properties: {
    #     Name: "my-api"
    #   },
    #   DependsOn: ["AnotherResource"]
    # )
    def add_resource(logical_id, type, options)
      base = { Type: type }

      options = if options.include?('Properties')
                  base.merge(options)
                else
                  {
                    Type: type,
                    Properties: options # options are properties
                  }
                end

      @template['Resources'][logical_id] = options
    end

    def add_parameters(attributes)
      attributes.each do |name,value|
        add_parameter(name.to_s.camelize, Description: value)
      end
    end

    def add_parameter(name, options={})
      defaults = { Type: "String" }
      options = defaults.merge(options)
      @template[:Parameters] ||= {}
      @template[:Parameters][name.camelize] = options
    end

    def add_outputs(attributes)
      attributes.each do |name,value|
        add_output(name.to_s.camelize, Value: value)
      end
    end

    def add_output(name, options={})
      @template[:Outputs] ||= {}
      @template[:Outputs][name.camelize] = options
    end

    def add_associated_resources
      @app_klass.tasks.each do |task|
        task.resources.each do |definition|
          resource = Jets::Resource.new(definition, task.replacements)
          add_associated_resource(resource)
          add_associated_resource(resource.permission)
        end
      end
    end

    def add_associated_resource(resource)
      add_resource(resource.logical_id, resource.type, resource.attributes)
    end
  end
end
