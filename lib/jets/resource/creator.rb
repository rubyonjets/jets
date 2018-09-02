module Jets::Resource
  class Creator
    extend Memoist

    def initialize(definition, task)
      @definition = definition
      @task = task # task that the definition belongs to
    end

    # Template snippet that gets injected into the CloudFormation template.
    def attributes
      Attributes.new(@definition, @task)
    end
    alias_method :resource, :attributes
    memoize :resource
    memoize :attributes
  end
end