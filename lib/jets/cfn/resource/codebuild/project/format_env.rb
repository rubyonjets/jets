module Jets::Cfn::Resource::Codebuild::Project
  module FormatEnv
    def standardize_env_vars(vars, casing: :camelcase_keys)
      map = {
        PARAMETER_STORE: "PARAMETER_STORE",
        SECRET: "SECRETS_MANAGER",
        SECRETS_MANAGER: "SECRETS_MANAGER",
        SSM: "PARAMETER_STORE"
      }

      vars = vars.reject { |k, v| v.nil? }

      # There's no map! method. So using map and then assigning to vars
      vars = vars.map do |k, v|
        starts_with = v.to_s.split(":").first
        value = if map.key?(starts_with.upcase.to_sym)
          v.to_s.sub("#{starts_with}:", "")
        else
          v
        end
        type = map[starts_with.upcase.to_sym] || "PLAINTEXT"
        {
          Name: k.to_s,
          Value: value,
          Type: type
        }
      end
      vars = vars.sort_by { |h| h[:Name].to_s }
      if casing == :underscore_keys
        vars.map! { |h| h.transform_keys { |k| k.to_s.underscore.to_sym } }
      end
      vars
    end
  end
end
