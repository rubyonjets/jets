class Jets::Job::Task
  attr_reader :name, :class_name
  def initialize(name, options)
    @name = name
    @options = options
    @rate = options[:rate]
    @cron = options[:cron]
    @class_name = options[:class_name].to_s
  end

  def meth
    @name
  end

  def schedule_expression
    if @rate
      "rate(#{@rate})"
    elsif @cron
      "cron(#{@cron})"
    end
  end
end
