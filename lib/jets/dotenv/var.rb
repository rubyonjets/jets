class Jets::Dotenv
  class Var
    extend Memoist
    include Jets::AwsServices
    include Jets::Util::Logging

    attr_reader :raw_key, :raw_value
    def initialize(raw_key, raw_value)
      @raw_key, @raw_value = raw_key, raw_value
    end

    def name
      @raw_key
    end

    def value
      ssm? ? ssm_value : @raw_value
    end
    memoize :value

    SSM_VARIABLE_REGEXP = /^SSM:(.*)/i
    def ssm_name
      if @raw_value == "SSM"
        # "/#{Jets.project.name}/#{Jets.env}/#{@raw_key}"
        Convention.new.ssm_name(@raw_key)
      else
        value = @raw_value.sub(/SSM:/i, "")
        if value.start_with?("/")
          value
        else
          # "/#{Jets.project.name}/#{Jets.env}/#{value}"
          Convention.new.ssm_name(value)
        end
      end
    end

    def ssm_value
      return "fake-ssm-value" if ENV["JETS_NO_INTERNET"]

      name = ssm_name
      resp = ssm.get_parameter(name: name, with_decryption: true)
      resp.parameter.value
    rescue Aws::SSM::Errors::ParameterNotFound
      @ssm_missing = true
      nil
    rescue Aws::SSM::Errors::ValidationException
      puts "ERROR: Invalid SSM parameter name: #{name.inspect}".color(:red)
      raise
    end

    def ssm_missing?
      value # trigger memoization
      !!@ssm_missing
    end

    def ssm?
      @raw_value&.start_with?("SSM")
    end
  end
end
