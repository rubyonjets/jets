class Jets::Commands::Call
  class AnonymousGuesser < BaseGuesser
    def detect_class_name
      found_path = function_paths.find do |path|
        File.exist?("#{Jets.root}/#{path}")
      end

      klass = Jets::Klass.from_path(found_path) if found_path
      klass.to_s
    end

    def method_name
      return @method_name if defined?(@method_name)

      full_function_name = @provided_function_name.underscore
      underscored_class_name = class_name.underscore
      meth = full_function_name.sub("#{underscored_class_name}_","")

      if meth == class_name.constantize.handler.to_s
        @method_name = meth
      else
        @method_name_error = "#{class_name} class found but #{meth} method not found"
        @method_name = nil
      end
    end

    # Useful to printing out what was attempted to look up
    def error_message
      guess_paths = function_paths
      puts "Unable to find the function to call."
      if class_name and !method_name
        puts @method_name_error
      else
        puts "Tried: #{guess_paths.join(', ')}"
      end
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

  end
end
