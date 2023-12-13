module Jets::Cfn::Resource::Codebuild::Project
  class Env
    include FormatEnv

    # config/jets/bootstrap.rb
    #
    #   Jets.bootstrap.configure do
    #     config.codebuild.project.env.vars
    #
    def vars
      vars = Jets.bootstrap.config.codebuild.project.env.vars.symbolize_keys!
      standardize_env_vars(vars)
    end

    # Used for codebuild.start_build in runner.rb
    def pass_vars(overrides = {})
      # config/jets/bootstrap.rb defined ENV vars
      env = Jets.bootstrap.config.codebuild.project.env

      vars = {}
      pass = (env.default_pass + env.pass).uniq

      # pass vars from your local machine to the codebuild remote runner
      pass.each do |x|
        ENV.each do |k, v|
          k = k.to_s
          match = x.is_a?(Regexp) ? k =~ x : k == x
          if match && v.is_a?(String)
            vars[k.to_sym] = v
          end
        end
      end

      # block gets the final say
      vars.reject! do |k, v|
        k = k.to_s
        env.block.any? do |x|
          x.is_a?(Regexp) ? k =~ x : k == x
        end
      end

      vars.merge!(overrides)

      standardize_env_vars(vars, casing: :underscore_keys)
    end

    def always_block
      %w[
        JETS_APP_SRC
        JETS_SIG
        JETS_TEMPLATES
      ]
    end
  end
end
