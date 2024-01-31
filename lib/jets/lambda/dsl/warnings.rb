module Jets::Lambda::Dsl
  module Warnings
    def iam_policy_unused_warning(managed=false)
      return unless show_iam_policy_unused_warning?

      managed_prefix = managed ? "managed_" : ""
      use_instead = case Jets.config.cfn.build.controllers
                    when "one_lambda_per_contoller"
                      "class_#{managed_prefix}iam_policy"
                    when "one_lambda_for_all_controllers"
                      "class_#{managed_prefix}iam_policy in the ApplicationController"
                    end
      puts <<~EOL.color(:yellow)
        WARNING: #{managed_prefix}iam_policy is not respected when config.cfn.build.controllers is not set to "one_lambda_per_controller"
        Current setting: config.cfn.build.controllers = "#{Jets.config.cfn.build.controllers}"
        Please use #{use_instead} instead.
        Docs: #{iam_docs_url(managed)}
      EOL

      DslEvaluator.print_code(app_call_line) if app_call_line
    end

    def class_iam_policy_unused_warning(managed=false)
      return unless Jets.config.cfn.build.controllers == "one_lambda_for_all_controllers"
      return if self.to_s == "ApplicationController" # ApplicationController not defined in job mode
      return if self.ancestors.include?(Jets::Job::Base)

      managed_prefix = managed ? "managed_" : ""
      puts <<~EOL.color(:yellow)
        WARNING: class_#{managed_prefix}iam_policy is not respected when
        config.cfn.build.controllers is not set to "one_lambda_per_controller" or "one_lambda_per_method"
        Current setting: config.cfn.build.controllers = "#{Jets.config.cfn.build.controllers}"
        Please use class_#{managed_prefix}iam_policy in the ApplicationController instead.
        Docs: #{iam_docs_url(managed)}
      EOL

      DslEvaluator.print_code(app_call_line) if app_call_line
    end

    def show_iam_policy_unused_warning?
      Jets.config.cfn.build.controllers != "one_lambda_per_method" &&
      self.name.include?("Controller")
    end

    def iam_docs_url(managed)
      if managed
        "http://rubyonjets.com/docs/managed-iam-policies/"
      else
        "http://rubyonjets.com/docs/iam-policies/"
      end
    end

    def app_call_line
      caller.find { |l| l.include?('app/controllers') }
    end
  end
end
