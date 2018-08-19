module Jets::Cfn::TemplateBuilders::IamPolicy
  class ClassPolicy < BasePolicy
    def initialize(app_class)
      setup
      @app_class = app_class
      # IE: @app_class: PostsController, HardJob, Hello, HelloFunction
      @definitions = app_class.class_iam_policy || [] # class_iam_policy contains definitions
    end

    # Example: PostsControllerPolicy or SleepJobPolicy
    # Note: There is no "method" in the name
    def policy_name
      "#{@app_class}_policy".camelize
    end
  end
end