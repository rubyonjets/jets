class Jets::Cfn::TemplateBuilders
  class IamPolicy
    extend Memoist

    attr_reader :definitions
    def initialize(task)
      @task = task # TODO: will break specs, fix specs
      @app_class = task.class_name.to_s
      # @app_class examples: PostsController, HardJob, Hello, HelloFunction

      @definitions = task.iam_policy # iam_policy contains definitions
      # empty starting policy that will be changed
      @policy = {
        "Version" => "2012-10-17",
        "Statement" => []
      }
      @sid = 0 # counter
    end

    # Example: SleepJobPerformLambdaFunction
    def logical_id
      "#{class_action}LambdaFunction".gsub('::','')
    end

    # Example: PostsControllerIndex or SleepJobPerform
    def class_action
      "#{@app_class}_#{@task.meth}".camelize
    end

    def resource
      definitions.map { |definition| standardize(definition) }
      # Thanks: https://www.mnishiguchi.com/2017/11/29/rails-hash-camelize-and-underscore-keys/
      @policy.deep_transform_keys! { |key| key.to_s.camelize }
    end
    memoize :resource # only process resource once

    def standardize(definition)
      @sid += 1
      case definition
      when String
        @policy["Statement"] << {
          "Sid"=>"Stmt#{@sid}",
          "Action"=>[definition],
          "Effect"=>"Allow", "Resource"=>"*",
        }
      when Hash
        definition = definition.stringify_keys
        if definition.key?("Version") # special case where we replace the policy entirely
          @policy = definition
        else
          @policy["Statement"] << definition
        end
      end
    end
  end
end
