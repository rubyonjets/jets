# The class including this module should implement these methods:
#
#   * compose
#   * template_path
module Jets::Cfn::Builders
  module Interface
    extend Memoist

    def build(parent=false)
      # Do not bother building or writing the template unless there are functions defined
      return if @app_class && !@app_class.build?

      if @options.nil? || @options[:templates] || @options[:stack_type] != :minimal || parent
        compose # must be implemented by subclass
      end
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

    def add_description(desc)
      @template[:Description] = desc
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
      @template[:Parameters][name.to_s.camelize] = Jets::Camelizer.transform(options)
    end

    def add_outputs(attributes)
      attributes.each do |name,value|
        add_output(name.to_s.camelize, Value: value)
      end
    end

    def add_output(name, options={})
      @template[:Outputs] ||= {}
      @template[:Outputs][name.camelize] = Jets::Camelizer.transform(options)
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

    # Note: Jets::Resource::Iam classes are special treated. They are the only resources that result
    # in creating 2 CloudFormation resources: Iam::Policy and Iam::Role.
    # This allows the user to refer to the Lambda Function name in the IAM Policy itself.
    # We need separate resources to avoid CloudFormation erroring with a circular dependency.
    # Using separate IAM::Policy and IAM::Role resources allows us avoid the circular dependency error.
    #
    # Handling logic here also centralizes code for this special behavior.
    # Also important to note, this does not change the user-facing interface.
    # IE: Users still uses code like:
    #
    #    iam_policy("s3", "sns")
    #
    # and be none-the-wiser about the special behavior.
    def add_resource(resource)
      add_template_resource(resource.logical_id, resource.type, resource.attributes)

      if resource.class.to_s.include?("Jets::Resource::Iam")
        role = resource # for clarity: resource is a Iam::*Role class
        iam_policy = Jets::Resource::Iam::Policy.new(role)
        add_template_resource(iam_policy.logical_id, iam_policy.type, iam_policy.attributes)
      end
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
