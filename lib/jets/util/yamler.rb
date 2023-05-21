# Named Yamler to make it clear it's not the YAML class.
class Jets::Util
  class Yamler
    class << self
      def load(text)
        options = RUBY_VERSION =~ /^3/ ? {aliases: true} : {} # Ruby 3.0.0 deprecates aliases: true
        YAML.load(text, **options)
      end

      def load_file(path)
        options = RUBY_VERSION =~ /^3/ ? {aliases: true} : {} # Ruby 3.0.0 deprecates aliases: true
        YAML.load_file(path, **options)
      end
    end
  end
end
