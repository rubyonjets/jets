class Jets::Lambda::Task
  attr_reader :meth, :properties
  def initialize(meth, options={})
    @meth = meth
    @options = options
    @properties = options[:properties] || {}
  end
end
