class Jets::Lambda::Task
  attr_reader :class_name, :meth, :properties
  def initialize(class_name, meth, options={})
    @class_name = class_name.to_s # use at EventsRuleMapper#full_task_name
    @meth = meth
    @options = options
    @properties = options[:properties] || {}
  end

  def name
    @meth
  end
end
