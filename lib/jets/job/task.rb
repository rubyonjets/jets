class Jets::Job::Task
  def initialize(meth, options)
    @meth = meth
    @options = options
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
