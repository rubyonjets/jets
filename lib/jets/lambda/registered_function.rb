class Jets::Lambda::RegisteredFunction
  attr_reader :meth, :properties
  def initialize(meth, options={})
    @meth = meth
    @options = options
    @properties = options[:properties] || {}
  end
end
