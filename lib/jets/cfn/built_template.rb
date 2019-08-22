module Jets::Cfn
  # Caches the built template to reduce filesystem IO calls.
  class BuiltTemplate
    class << self
      @@cache = {}
      def get(path)
        if @@cache[path]
          @@cache[path] # using cache
        else
          @@cache[path] = YAML.load_file(path) # setting and using cache
        end
      end
    end
  end
end
