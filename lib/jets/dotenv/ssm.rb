require 'aws-sdk-ssm'

class Jets::Dotenv
  class Ssm
    SSM_VARIABLE_REGEXP = /^ssm:(.*)/

    def initialize(variables={})
      @variables = variables
      @missing = []
    end

    def interpolate!
      interpolated_variables = @variables.map do |key, value|
        if value[SSM_VARIABLE_REGEXP]
          value = fetch_ssm_value(key, $1)
        end

        [key, value]
      end

      interpolated_variables.each do |key, value|
        ENV[key] = value
      end

      if @missing.empty?
        interpolated_variables.to_h.sort_by { |k,_| k }.to_h # success
      else
        message = "Error loading .env variables. No matching SSM parameters found for:\n".color(:red)
        message += @missing.map { |k,v,n| "  #{k}=ssm:#{v} # ssm name: #{n}"}.join("\n")
        abort message
      end
    end

    def fetch_ssm_value(key, value)
      return "fake-ssm-value" if ENV['JETS_BUILD_NO_INTERNET']

      name = value.start_with?("/") ? value :
        "/#{Jets.config.project_name}/#{Jets.env}/#{value}"
      response = ssm.get_parameter(name: name, with_decryption: true)
      response.parameter.value
    rescue Aws::SSM::Errors::ParameterNotFound
      @missing << [key, value, name]
      ''
    end

    def ssm
      @ssm ||= Aws::SSM::Client.new
    end
  end
end
