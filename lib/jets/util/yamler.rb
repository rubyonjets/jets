# Named Yamler to make it clear it's not the YAML class.
class Jets::Util
  class Yamler
    class << self
      def load(text)
        options = { permitted_classes: [Date] }
        options[:aliases] = true if RUBY_VERSION =~ /^3/ # Ruby 3.0.0 deprecates aliases: true
        YAML.load(text, **options)
      end

      def load_file(path)
        options = { permitted_classes: [Date] }
        options[:aliases] = true if RUBY_VERSION =~ /^3/ # Ruby 3.0.0 deprecates aliases: true
        YAML.load_file(path, **options)
      end
    end
  end
end
