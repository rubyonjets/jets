require 'aws-sdk-ssm'

class Jets::Dotenv
  class Ssm
    SSM_VARIABLE_REGEXP = /^ssm:(.*)/i

    def initialize(variables={})
      @variables = variables
      @missing = []
    end

    def interpolate!
      interpolated_variables = @variables.map do |key, value|
        if value[SSM_VARIABLE_REGEXP]
          value = fetch_ssm_value(key, $1)
        elsif value == "SSM"
          value = fetch_ssm_value(key, "SSM")
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
        message += @missing.map do |k,v,n|
          value = v == "SSM" ? v : "ssm:#{v}"
          "  #{k}=#{value} # ssm name: #{n}"
        end.join("\n")
        abort message
      end
    end

    def fetch_ssm_value(key, value)
      return "fake-ssm-value" if ENV['JETS_BUILD_NO_INTERNET']

      name = ssm_name(key, value)
      response = ssm.get_parameter(name: name, with_decryption: true)
      response.parameter.value
    rescue Aws::SSM::Errors::ParameterNotFound
      @missing << [key, value, name]
      ''
    end

    def ssm_name(key, value)
      if value == "SSM"
        "/#{Jets.config.project_name}/#{Jets.env}/#{key}"
      else
        value.start_with?("/") ?
          value :
          "/#{Jets.config.project_name}/#{Jets.env}/#{value}"
      end
    end

    def ssm
      @ssm ||= Aws::SSM::Client.new
    end
  end
end
