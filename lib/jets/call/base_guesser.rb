# Subclasses must implement this interface:
#   detect_class_name
#   method_name
#   error_message
#
# Transforms the user provided function name to the actual lambda
# function name.
#
# Allow for variety of different inputs to work:
# Simple:
#   admin/pages_controller-index => admin-pages_controller-index
#   admin-pages_controller-index => admin-pages_controller-index
#
# Complex, requires detecting the right class name:
#   admin/related_pages_controller-list_all
#   admin-related-pages-controller-list-all
#
# All still result in: admin-related_pages_controller-index
#
# The detection process follows. Given worse case:
#   admin-related-pages-controller-list-all
#
# Know that the action comes after controller, try:
#   AdminRelatedPagesController
#   Admin::RelatedPagesController <= found stop guessing
#
# admin/related_pages_controller <= underscored
# admin/related_pages_controller-list_all <= add action back on
# admin-related_pages_controller-list_all <= gsub / - DONE
#
# Now we're at a point where we can start guessing
# function_name = detect_function_name(function_name)
class Jets::Call
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
