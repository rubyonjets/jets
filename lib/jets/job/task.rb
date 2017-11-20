class Jets::Job::Task < Jets::Lambda::Task
  def initialize(class_name, meth, options={})
    super
    @rate = options[:rate]
    @cron = options[:cron]
  end

  def schedule_expression
    if @rate
      "rate(#{@rate})"
    elsif @cron
      "cron(#{@cron})"
    end
  end
end
