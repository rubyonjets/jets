# The class including this module should implement these methods:
#
#   * compose
#   * template_path
class Jets::Cfn::Builders
  module Interface
    extend Memoist

    def build
      # Do not bother building or writing the template unless there are functions defined
      return if @app_class && !@app_class.build?

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

    def add_parameters(attributes)
      attributes.each do |name,value|
        add_parameter(name.to_s.camelize, Description: value)
      end
    end

    def add_parameter(name, options={})
      defaults = { Type: "String" }
      options = defaults.merge(options)
      @template[:Parameters] ||= {}
      @template[:Parameters][name.to_s.camelize] = options
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

    def add_resources
      @app_class.tasks.each do |task|
        task.associated_resources.each do |associated|
          resource = Jets::Resource.new(associated.definition, task.replacements)
          add_resource(resource)
          add_resource(resource.permission)
        end
      end
    end

    def add_resource(resource)
      add_template_resource(resource.logical_id, resource.type, resource.attributes)
    end

    # The add_resource method can take an options Hash with both with either
    # top level attributes or properties.
    #
    # Example:
    #
    # Top level options:
    #
    #   add_template_resource("MyId", "AWS::ApiGateway::RestApi",
    #     type: "AWS::ApiGateway::RestApi",
    #     properties: {
    #       name: "my-api"
    #     },
    #     depends_on: ["AnotherResource"]
    #   )
    #
    # Simple options with properties only:
    #
    #   add_template_resource("MyId", "AWS::CloudFormationStack",
    #     template_url: "template_url",
    #     parameters: {},
    #   )
    #
    def add_template_resource(logical_id, type, options)
      options = Jets::Camelizer.transform(options)

      attributes = if options.include?('Type')
                     base = { 'Type' => type }
                     base.merge(options) # options are top-level attributes
                   else
                     {
                       'Type' => type,
                       'Properties' => options # options are properties
                     }
                   end

      @template['Resources'][logical_id] = attributes
    end
  end
end
