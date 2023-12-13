module Jets::CLI::Lambda
  class Function
    include Jets::AwsServices
    attr_reader :function_name
    alias_method :name, :function_name

    def initialize(function_name)
      @function_name = function_name
    end

    # Environment Variables
    def environment_variables
      response = lambda_client.get_function_configuration(function_name: function_name)
      response.environment.variables.sort.to_h
    end

    def environment_variables=(env_vars)
      current_env = environment_variables

      # Update existing vars and remove vars set to nil
      updated_env = current_env.merge(env_vars.stringify_keys) { |key, old_val, new_val| new_val.nil? ? nil : new_val }
      updated_env.compact!  # Removes all key-value pairs where value is nil

      lambda_client.update_function_configuration(
        function_name: function_name,
        environment: {variables: updated_env}
      )
    end

    # Reserved Concurrency
    def reserved_concurrency
      response = lambda_client.get_function_concurrency(function_name: function_name)
      response.reserved_concurrent_executions
    rescue Aws::Lambda::Errors::ResourceNotFoundException
      nil  # No reserved concurrency set implies no limit
    end

    def reserved_concurrency=(concurrency)
      if concurrency.nil?
        lambda_client.delete_function_concurrency(function_name: function_name)
      else
        lambda_client.put_function_concurrency(
          function_name: function_name,
          reserved_concurrent_executions: concurrency
        )
      end
    end

    def provisioned_concurrency(qualifier = "live")
      info = provisioned_concurrency_info(qualifier)
      (info[:status] == "not set") ? nil : info[:requested]
    end

    # Provisioned Concurrency
    def provisioned_concurrency_info(qualifier = "live")
      response = lambda_client.get_provisioned_concurrency_config(
        function_name: function_name,
        qualifier: qualifier
      )
      {
        requested: response.requested_provisioned_concurrent_executions,
        allocated: response.allocated_provisioned_concurrent_executions,
        status: response.status
      }
    rescue Aws::Lambda::Errors::ResourceNotFoundException,
      Aws::Lambda::Errors::ProvisionedConcurrencyConfigNotFoundException
      {
        status: "not set"
      }
    end

    def provisioned_concurrency=(concurrency, qualifier = "live")
      if concurrency.nil? || concurrency == 0
        begin
          lambda_client.delete_provisioned_concurrency_config(
            function_name: function_name,
            qualifier: qualifier
          )
        rescue Aws::Lambda::Errors::ResourceNotFoundException
        end
      else
        lambda_client.put_provisioned_concurrency_config(
          function_name: function_name,
          qualifier: qualifier,
          provisioned_concurrent_executions: concurrency
        )
      end
    end

    # Check if reserved concurrency is zero or not set
    def reserved_concurrency_zero?
      reserved_concurrency == 0
    end

    # Check if provisioned concurrency is unset
    def provisioned_concurrency_unset?(qualifier = "live")
      pc = provisioned_concurrency(qualifier)
      pc.nil? || (pc[:requested] == 0 && pc[:allocated] == 0)
    rescue Aws::Lambda::Errors::ResourceNotFoundException,
      Aws::Lambda::Errors::ProvisionedConcurrencyConfigNotFoundException
      true  # Treat not found as unset
    end
  end
end
