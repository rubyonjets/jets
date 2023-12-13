class Jets::CLI::Maintenance::Worker
  class Zeroer < Base
    def zero_all_concurrency
      lambda_functions.each do |lambda_function|
        # must zero provisioned before reserved
        lambda_function.provisioned_concurrency = nil
        lambda_function.reserved_concurrency = 0
      end
    end

    def all_zeroed?
      lambda_functions.all? do |lambda_function|
        # check both reserved and provisioned
        lambda_function.provisioned_concurrency_unset? &&
          lambda_function.reserved_concurrency_zero?
      end
    end
  end
end
