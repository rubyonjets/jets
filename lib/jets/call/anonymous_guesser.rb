class Jets::Call
  class AnonymousGuesser < Guesser
    def function_underscored_name
      name = @provided_function_name.gsub('-','_')
      name.split('_')[0..-2].join('_') # remove last word
      # So:
      #   hello-world => hello
      #   simple-function-handler => simple-function
    end

    def function_filenames(meth=nil, primary_namespace=nil)
      guesses = []
      parts = meth.split('_')

      if primary_namespace.nil?
        guesses << meth

        if parts.size == 1 # already on final_primary_namespace
          return guesses # end of recursion
        else
          next_primary_namespace =  parts.first
          guesses += function_filenames(meth, next_primary_namespace) # start of recursion
          return guesses # return early
        end
      end

      next_meth = meth.sub("#{primary_namespace}_", '')
      next_parts = next_meth.split('_')

      # puts "next_meth #{next_meth.inspect}"
      # puts "next_parts #{next_parts.inspect}"

      # Takes the next_parts and creates guesses with the parts joined by '/'
      # with the primary_namespace prepended.  So if next_parts is
      # ["long", "name", "function"] and primary_namespace is "complex"
      #
      # guesses that get added:
      #
      #   [
      #     "complex/long_name_function",
      #     "complex/long/name_function",
      #     "complex/long/name/function",
      #   ]
      n = next_parts.size + 1
      next_parts.size.times do |i|
        namespace = i == 0 ? nil : next_parts[0..i-1].join('/')
        class_path = next_parts[i..-1].join('_')
        guesses << [primary_namespace, namespace, class_path].compact.join('/')
      end

      final_primary_namespace = parts[0..-2].join('_')
      if primary_namespace == final_primary_namespace
        return guesses # end of recursion
      else
        namespace_size = parts.size - next_parts.size
        next_primary_namespace = parts[0..namespace_size].join('_')
        guesses += function_filenames(meth, next_primary_namespace)
        return guesses
      end
    end

    def function_paths
      # drop the last word for starting filename
      starting_filename = @provided_function_name.underscore.split('_')[0..-2].join('_')
      filenames = function_filenames(starting_filename)
      filenames.map do |name|
        "app/functions/#{name}.rb"
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

    def guess_classes
      autoload_paths.map(&:classify)
    end

    def out_of_guesses(guess)
      guess.include?("::Controller")
    end

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

      # Functions are anonymous classes, so
      function_paths

      nil
    end

  end
end
