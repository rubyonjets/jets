module Jets::CLI::Lambda
  module Functions
    extend Memoist
    def lambda_functions
      names = Jets::CLI::Functions.new(full: true).all
      names.map { |name| Jets::CLI::Lambda::Function.new(name) }
    end
    memoize :lambda_functions
  end
end
