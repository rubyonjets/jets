require "active_support/core_ext/hash"
require "active_support/core_ext/object"

# Guesser transforms the user provided function name to the actual lambda
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
class Jets::Commands::Call
  class Guesser
    delegate :class_name, :method_name, :error_message, :function_name,
      to: :delegate_guesser

    # Example of provided_function_name:
    #   admin/related_pages_controller-list_all
    #   admin-related-pages-controller-list-all
    def initialize(provided_function_name)
      @provided_function_name = provided_function_name
    end

    def delegate_guesser
      @delegate_guesser ||= if @provided_function_name =~ /[-_](controller|job|rule)/
                              AutoloadGuesser.new(@provided_function_name)
                            else
                              AnonymousGuesser.new(@provided_function_name)
                            end
    end
  end
end
