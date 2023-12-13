# The class including this module should implement these methods:
#
#   * compose
#   * template_path
#
module Jets::Cfn::Builder
  module Interface
    extend Memoist
    include Jets::Util::Camelize

    def build
      return unless build?
      compose # must be implemented by subclass
      write
    end

    # Do not bother building or writing the template unless there are functions defined
    def build?
      build = @app_class && !@app_class.build?
      !build
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
      # -1 means unlimited line width, it prevents the YAML.dump from wrapping
      # Otherwise the PostProcess class will not work properly.
      text = YAML.dump(template, line_width: -1)
      # post process the text so that
      # "!Ref IamRole" => !Ref IamRole
      # We strip the surrounding quotes
      PostProcess.new(text).process
    end

    def add_description(desc)
      @template[:Description] = desc
    end

    def add_parameters(attributes)
      attributes.each do |name, value|
        add_parameter(name.camelize.to_sym, Description: value)
      end
    end

    def add_parameter(name, options = {})
      defaults = {Type: "String"}
      options = defaults.merge(options)
      @template[:Parameters] ||= {}
      @template[:Parameters][name.camelize.to_sym] = camelize(options)
    end

    def add_outputs(attributes)
      attributes.each do |name, value|
        add_output(name.camelize.to_sym, Value: value)
      end
    end

    def add_output(name, options = {})
      @template[:Outputs] ||= {}
      @template[:Outputs][name.camelize.to_sym] = camelize(options)
    end

    # Note: Jets::Cfn::Resource::Iam classes are special treated.
    # They are only a few resources that result in creating 2 CloudFormation resources.
    # Cfn::Builder::Api::Methods also creates a method, permission, and possible cors resource.
    # Though that is more of an internal Jets resource.
    # In this case for Iam, both Iam::Policy and Iam::Role are created.
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
    # and are none-the-wiser about the special behavior.
    #
    def add_resource(resource)
      add_template_resource(resource.logical_id, resource.type, resource.attributes)
      add_outputs(resource.outputs)
    end

    # The add_resource method can take an options Hash with both with either
    # top level attributes or properties.
    #
    # Example:
    #
    # Top level options:
    #
    #   add_template_resource("MyId", "AWS::ApiGateway::RestApi",
    #     Type: "AWS::ApiGateway::RestApi",
    #     Properties: {
    #       Name: "my-api"
    #     },
    #     DependsOn: ["AnotherResource"]
    #   )
    #
    # Simple options with properties only:
    #
    #   add_template_resource("MyId", "AWS::CloudFormationStack",
    #     TemplateURL: "template_url",
    #     Parameters: {},
    #   )
    #
    def add_template_resource(logical_id, type, options)
      options = camelize(options)

      attributes = if options.include?(:Type)
        base = {Type: type}
        base.merge(options) # options are top-level attributes
      else
        {
          Type: type,
          Properties: options # options are properties
        }
      end

      @template[:Resources][logical_id] = attributes
    end

    # interface method
    def config
      Jets.bootstrap.config
    end
  end
end
