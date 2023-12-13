class Jets::Dotenv
  class Convention
    extend Memoist
    delegate :config, to: "Jets.project"
    delegate :env, to: Jets

    # ssm leaf name is the name of the leaf in the SSM parameter store.
    # It can come from the key or the value.
    #
    #   DATABASE_URL=SSM        => DATABASE_URL
    #   DATABASE_URL=SSM:DB_URL => DB_URL
    #
    #
    # Full SSM name. Example:
    #
    #   /project/dev/DATABASE_URL
    #   /project/dev/DB_URL
    #
    def ssm_name(ssm_leaf_name)
      if config.dotenv.ssm.convention_resolver
        config.dotenv.ssm.convention_resolver.call(ssm_leaf_name)
      else
        "#{self.class.ssm_path}#{ssm_leaf_name}"
      end
    end

    class << self
      extend Memoist
      delegate :config, to: "Jets.project"
      delegate :env, to: Jets

      def ssm_path
        project = config.dotenv.ssm.project_name || Jets.project.name
        # consider long_env config in the ssm_name only
        ssm_env = config.dotenv.ssm.long_env_name ? resolved_long_env : resolved_env

        "/#{project}/#{ssm_env}/"
      end

      # Does not use the envs.fallbakc and envs.unique settings.
      def jets_env_path
        project = config.dotenv.ssm.project_name || Jets.project.name
        ssm_env = config.dotenv.ssm.long_env_name ? (long_env_map[Jets.env.to_sym] || Jets.env) : Jets.env

        "/#{project}/#{ssm_env}/"
      end

      def ssm_env
        config.dotenv.ssm.long_env_helper ? resolved_long_env : resolved_env
      end

      def resolved_env
        if unique_env?(env)
          env # IE: dev or prod
        else
          config.dotenv.ssm.envs.fallback # IE: dev
        end
      end

      def unique_env?(env)
        config.dotenv.ssm.envs.unique.nil? ||
          config.dotenv.ssm.envs.unique == :all ||
          config.dotenv.ssm.envs.unique.include?(env)
      end

      def resolved_long_env
        short_env = resolved_env
        long_env_map[short_env.to_sym] || short_env
      end

      # Jets 5.0 legacy
      def long_env
        short_env = Jets.env.to_s
        long_env_map[short_env.to_sym] || short_env
      end

      def long_env_map
        {
          dev: "development",
          prod: "production",
          stag: "staging"
        }
      end
    end
  end
end
