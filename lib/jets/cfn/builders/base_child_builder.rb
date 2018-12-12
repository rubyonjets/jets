# Implements:
#
#   * template_path
#
# FYI
#
#   * compose implemented by the classes that include this
class Jets::Cfn::Builders
  class BaseChildBuilder
    include Interface

    # The app_class is can be a controller, job or anonymous function class.
    # IE: PostsController, HardJob
    def initialize(app_class)
      @app_class = app_class
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # template_path is an interface method for Interface module
    def template_path
      Jets::Naming.app_template_path(@app_class)
    end

    def add_common_parameters
      common_parameters = Jets::Resource::ChildStack::AppClass.common_parameters
      common_parameters.each do |k,_|
        add_parameter(k, Description: k)
      end

      depends_on_params.each do |logical_id, desc|
        add_parameter(logical_id, Description: desc)
      end
    end

    def depends_on_params
      return {} unless @app_class.depends_on

      params = {}
      @app_class.depends_on.each do |shared_stack|
        dependency = shared_stack.to_s.camelize # logical_id
        dependency_outputs(dependency).each do |output|
          dependency_class = dependency.to_s.classify
          desc = "From #{dependency_class}.Outputs.#{output}"
          # key: logical_id , value: description
          params[output] = desc
        end
      end
      params
    end

    def dependency_outputs(dependency)
      dependency.to_s.classify.constantize.output_keys
    end

    def add_functions
      add_class_iam_policy
      @app_class.tasks.each do |task|
        add_function(task)
        add_function_iam_policy(task)
      end
    end

    def add_function(task)
      resource = Jets::Resource::Lambda::Function.new(task)
      add_resource(resource)
    end

    def add_class_iam_policy
      return unless @app_class.build_class_iam?

      resource = Jets::Resource::Iam::ClassRole.new(@app_class)
      add_resource(resource)
    end

    def add_function_iam_policy(task)
      return unless task.build_function_iam?

      resource = Jets::Resource::Iam::FunctionRole.new(task)
      add_resource(resource)
    end
  end
end
