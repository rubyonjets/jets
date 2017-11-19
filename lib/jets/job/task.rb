class Jets::Job::Task < Jets::Lambda::Task
  attr_reader :meth, :class_name
  def initialize(meth, options={})
    super
    @rate = options[:rate]
    @cron = options[:cron]
    @class_name = options[:class_name].to_s # use at EventsRuleMapper#full_task_name
  end

  def name
    @meth
  end

  def schedule_expression
    if @rate
      "rate(#{@rate})"
    elsif @cron
      "cron(#{@cron})"
    end
  end
end
