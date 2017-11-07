class Jets::Job::Task
  attr_reader :meth
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
