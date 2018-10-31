module Jets::Gems
  class Check
    def initialize(options)
      @options = options
    end

    def run
      puts "Checking projects gems are available as pre-built Lambda gems..."

      specs_with_extensions.each do |spec|
        puts "Checking #{spec.name}..."
      end
    end

    # Thanks: https://gist.github.com/aelesbao/1414b169a79162b1d795 and
    #   https://stackoverflow.com/questions/5165950/how-do-i-get-a-list-of-gems-that-are-installed-that-have-native-extensions
    def specs_with_extensions
      Gem::Specification.each.select { |spec| spec.extensions.any?  }
    end
  end
end