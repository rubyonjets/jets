require 'aws-sdk-ssm'

class Jets::Dotenv
  class Ssm
    SSM_VARIABLE_REGEXP = /^ssm:(.*)/

    def initialize(variables={})
      @variables = variables
    end

    def interpolate!
      interpolated_variables = @variables.map do |key, value|
        if value[SSM_VARIABLE_REGEXP]
          value = fetch_ssm_value($1)
        end

        [key, value]
      end

      interpolated_variables.each do |key, value|
        ENV[key] = value
      end

      interpolated_variables.to_h
    end

    def fetch_ssm_value(name)
      name = "/#{Jets.application.config.project_name}/#{Jets.env}/#{name}" unless name.start_with?("/")
      response = ssm.get_parameter(name: name, with_decryption: true)
      response.parameter.value
    rescue Aws::SSM::Errors::ParameterNotFound
      abort "Error loading .env variables. No parameter matching #{name} found on AWS SSM.".color(:red)
    end

    def ssm
      @ssm ||= Aws::SSM::Client.new
    end
  end
end