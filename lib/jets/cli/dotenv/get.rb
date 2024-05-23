class Jets::CLI::Dotenv
  class Get < Base
    def run
      vars = Jets::Dotenv.parse
      vars.find do |name, value|
        if name == @options[:name]
          puts value
          exit # success
        end
      end
      exit 1 # not found
    end
  end
end
