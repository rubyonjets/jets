module Jets::Resource
  class Creator
    extend Memoist

    def initialize(definition, task)
      @definition = definition
      @task = task # task that the definition belongs to
    end

    # Template snippet that gets injected into the CloudFormation template.
    def resource
      Attributes.new(@definition, @task)
    end
    memoize :resource

    def permission
      permission = Permission.new(@task)
      permission
    end
    memoize :permission
  end
end