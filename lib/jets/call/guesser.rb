# Transforms the user provided function name to the actual lambda
# function name.
#
# Allow for variety of different inputs to work:
# Simple:
#   admin/pages_controller-index => admin-pages_controller-index
#   admin-pages_controller-index => admin-pages_controller-index

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

# Now we're at a point where we can start guessing
# function_name = detect_function_name(function_name)

class Jets::Call
  class Guesser
    # provided_function_name:
    #   admin/related_pages_controller-list_all
    #   admin-related-pages-controller-list-all
    def initialize(provided_function_name)
      @provided_function_name = provided_function_name
    end

    def class_name
      @class_name ||= detect_class_name
    end

    def method_name
      return @method_name if defined?(@method_name)
      return nil unless class_name

      underscored_class_name = class_name.underscore.gsub('/','_')
      underscored_function_name = @provided_function_name.underscore.gsub('/','_')
      meth = underscored_function_name.sub(underscored_class_name, '')
      meth = meth.sub(/^[-_]/,'') # remove leading _ or -

      if class_name.constantize.public_instance_methods.include?(meth.to_sym)
        @method_name = meth
      else
        @method_name_error ="#{class_name} class found but #{meth} method not found"
        @method_name = nil
      end
    end

    def function_name
      # Strip the project namespace if the user has accidentally added it
      # Since we're going to automatically add it no matter what at the end
      # and dont want the namespace to be included twice
      @provided_function_name = @provided_function_name.sub("#{Jets.config.project_namespace}-", "")

      code_path = class_name.underscore.gsub('/','-')
      function_name = [Jets.config.project_namespace, code_path, action_name].join('-')
    end

    def process_type
      if @provided_function_name.include?('controller')
        "controller"
      elsif @provided_function_name.include?('job')
        "job"
      else
        # TODO: Guesser: handle process_type better when user doesnt provide controller or job in the name
        nil
      end
    end

    def action_name
      md = @provided_function_name.match(process_type_pattern)
      action_name = md[1]
      action_name.gsub('-','_')
    end

    def process_type_pattern
      Regexp.new("[-_]#{process_type}[-_](.*)")
    end

    # strips the action because we dont want it to guess the class name
    def underscored_name
    # strip action and concidentally the _controller_ string
    name = @provided_function_name.sub(process_type_pattern,'')
    name = name.gsub('-','_') + "_#{process_type}"
    # So:
    # name: admin-related-pages
    # name: admin_related_pages_controller
    end

    # underscored_name: admin_related_pages_controller
    # Returns:
    #   [
    #     "admin_related_pages_controller",
    #     "admin/related_pages_controller",
    #     "admin_related/pages_controller",
    #     "admin_related_pages/controller",
    #   ]
    def guess_paths
      guesses = []

      parts = underscored_name.split('_')
      parts.size.times do |i|
        namespace = i == 0 ? nil : parts[0..i-1].join('/')
        class_path = parts[i..-1].join('_')
        guesses << [namespace, class_path].compact.join('/')
      end

      guesses
    end

    # Useful to printing out what was attempted to look up
    def error_message
      guesses = guess_classes
      puts "Unable to find the function to call."
      if class_name and !method_name
        puts @method_name_error
      else
        puts "Tried: #{guesses.join(', ')}"
      end
    end

    def guess_classes
      guess_paths.map(&:classify)
    end

    def out_of_guesses(guess)
      guess.include?("::Controller")
    end

    def detect_class_name
      Jets.boot # require to detect the right class exists

      guess_classes.each do |class_name_guess|
        begin
          class_name_guess.constantize
          return class_name_guess # if there's no error then the class is found
        rescue NameError
          if out_of_guesses(class_name_guess)
            # puts "Unable to find the class to call. Tried guessing: #{guess_classes[0..-2].join(', ')}."
            # raise # re-raise NameError for now but maybe better to provide
              # a custom error class, so we can rescue it and provide a
              # friendly message to the user
          else
            next
          end
        end
      end

      nil
    end

  end
end
