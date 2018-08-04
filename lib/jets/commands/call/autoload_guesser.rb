class Jets::Commands::Call
  class AutoloadGuesser < BaseGuesser
    def detect_class_name
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

    def method_name
      return @method_name if defined?(@method_name)
      return nil unless class_name

      underscored_class_name = class_name.underscore.gsub('/','_')
      underscored_function_name = @provided_function_name.underscore.gsub('/','_')
      meth = underscored_function_name.sub(underscored_class_name, '')
      meth = meth.sub(/^[-_]/,'') # remove leading _ or -

      if class_name.constantize.tasks.map(&:meth).include?(meth.to_sym)
        @method_name = meth
      else
        @method_name_error ="#{class_name} class found but #{meth} method not found"
        @method_name = nil
      end
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

    def process_type
      if @provided_function_name =~ /[-_]controller/
        "controller"
      elsif @provided_function_name =~ /[-_]job/
        "job"
      elsif @provided_function_name =~ /[-_]rule/
        "rule"
      else
        "function"
      end
    end

    def process_type_pattern
      Regexp.new("[-_]#{process_type}[-_](.*)")
    end

    # Strips the action because we dont want it to guess the class name
    # So:
    #   admin-related-pages => admin_related_pages_controller
    def underscored_name
      # strip action and concidentally the _controller_ string
      name = @provided_function_name.sub(process_type_pattern,'')
      # Ensure _controller or _job at the end except for simple functions
      unless process_type == "function"
        name = name.gsub('-','_') + "_#{process_type}"
      end
      name
    end

    # Guesses autoload paths.
    #
    # underscored_name: admin_related_pages_controller
    # Returns:
    #   [
    #     "admin_related_pages_controller",
    #     "admin/related_pages_controller",
    #     "admin_related/pages_controller",
    #     "admin_related_pages/controller",
    #   ]
    def autoload_paths
      guesses = []

      parts = underscored_name.split('_')
      parts.size.times do |i|
        namespace = i == 0 ? nil : parts[0..i-1].join('/')
        class_path = parts[i..-1].join('_')
        guesses << [namespace, class_path].compact.join('/')
      end

      guesses
    end

    def guess_classes
      autoload_paths.map(&:classify)
    end

    def out_of_guesses(guess)
      guess.include?("::Controller")
    end

  end
end
