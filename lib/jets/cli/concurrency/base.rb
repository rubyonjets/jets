class Jets::CLI::Concurrency
  class Base < Jets::CLI::Base
    include Jets::CLI::Lambda::Checks
    include Jets::Util::Truthy

    def initialize(options = {})
      super
      check_deployed!
    end

    def account_limit
      response = lambda_client.get_account_settings
      response.account_limit
    end
    memoize :account_limit
  end
end
