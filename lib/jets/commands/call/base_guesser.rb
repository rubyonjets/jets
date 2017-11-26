# Subclasses of BaseGuessor must implement interface:
#   detect_class_name
#   method_name
#   error_message
#
class Jets::Commands::Call
  class BaseGuesser
    # provided_function_name:
    #   admin/related_pages_controller-list_all
    #   admin-related-pages-controller-list-all
    def initialize(provided_function_name)
      @provided_function_name = provided_function_name
    end

    def class_name
      return @class_name if @detection_ran

      @class_name = detect_class_name
      @detection_ran = true
      @class_name
    end

    def function_name
      # Strip the project namespace if the user has accidentally added it
      # Since we're going to automatically add it no matter what at the end
      # and dont want the namespace to be included twice
      @provided_function_name = @provided_function_name.sub("#{Jets.config.project_namespace}-", "")

      code_path = class_name.underscore.gsub('/','-')
      function_name = [Jets.config.project_namespace, code_path, method_name].join('-')
    end
  end
end
