# Implements:
#   initialize
#   policy_name
#
module Jets::Cfn::TemplateBuilders::IamPolicy
  class FunctionPolicy < BasePolicy
    def initialize(task)
      setup
      @task = task
      @app_class = task.class_name.to_s
      # IE: @app_class: PostsController, HardJob, Hello, HelloFunction

      @definitions = task.iam_policy || [] # iam_policy contains definitions
    end

    # Example: PostsControllerIndexPolicy or SleepJobPerformPolicy
    def policy_name
      "#{@app_class}_#{@task.meth}_policy".gsub('::','_').camelize
    end
  end
end