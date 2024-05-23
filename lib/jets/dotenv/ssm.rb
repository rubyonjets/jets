class Jets::Dotenv
  class Ssm
    include Jets::AwsServices
    include Jets::Util::Logging

    def initialize(variables)
      @variables = variables
      @missing = []
    end

    def interpolate!
      interpolated_vars = merged_variables.map do |key, value|
        var = Var.new(key, value)
        @missing << var if var.ssm_missing?
        var
      end

      interpolated_vars.each do |var|
        ENV[var.name] = var.value
      end

      if @missing.empty?
        interpolated_vars.map { |var| [var.name, var.value] }.sort.to_h # success
      else
        message = "Error loading .env variables. No matching SSM parameters found for:\n".color(:red)
        message += @missing.map do |var|
          "    #{var.name}=#{var.raw_value} # ssm name: #{var.ssm_name}"
        end.join("\n")
        abort message
      end
    end

    # Merges the variables from the dotenv files with the conventional ssm variables
    # inferred by path, IE: /demo/dev/
    # User defined config/jets/env files values win over inferred ssm variables.
    def merged_variables
      if Jets.project.dotenv.ssm.autoload.enable
        ssm_vars = get_ssm_parameters_path(Convention.ssm_path) # IE: /demo/dev/
        if Convention.jets_env_path != Convention.ssm_path
          jets_env_vars = get_ssm_parameters_path(Convention.jets_env_path) # IE: /demo/sbx/
          ssm_vars = ssm_vars.merge(jets_env_vars)
        end

        # skip list
        ssm_vars = ssm_vars.delete_if { |k, v| skip_list?(k) }

        # optimization: no need to get vars with SSM values since they are already in ssm_vars
        vars = @variables.dup.delete_if { |k, v| v == "SSM" && ssm_vars.key?(k) }
        ssm_vars.merge(vars)
      else
        @variables
      end
    end

    def skip_list?(key)
      key = key.to_s
      a = Jets.project.dotenv.ssm.autoload
      skip_list = a.default_skip + a.skip
      skip_list.detect do |i|
        if i.is_a?(Regexp)
          key.match(i)
        else
          key == i
        end
      end
    end

    def get_ssm_parameters_path(path)
      if ARGV.include?("dotenv") && ARGV.include?("list")
        warn "# Autoloading SSM parameters within path #{path}"
      end
      parameters = {}
      next_token = nil

      loop do
        resp = ssm.get_parameters_by_path(path: path, with_decryption: true, next_token: next_token)

        resp.parameters.each do |param|
          key = param.name.sub(path, "")
          parameters[key] = param.value
        end

        next_token = resp.next_token
        break unless next_token
      end

      parameters
    end
  end
end
