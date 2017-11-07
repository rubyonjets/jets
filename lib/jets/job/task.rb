class Jets::Job::Task
  attr_reader :meth, :class_name
  def initialize(meth, options)
    @meth = meth
    @options = options
    @rate = options[:rate]
    @cron = options[:cron]
    @class_name = options[:class_name].to_s
  end

  def schedule_expression
    if @rate
      "rate(#{@rate})"
    elsif @cron
      "cron(#{@cron})"
    end
  end
end
