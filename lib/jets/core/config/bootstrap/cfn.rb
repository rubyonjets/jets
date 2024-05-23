class Jets::Core::Config::Bootstrap
  module Cfn
    attr_accessor :cfn

    def initialize(*)
      super

      @cfn = ActiveSupport::OrderedOptions.new
      @cfn.resource_tags = {} # tags to add to all resources
    end
  end
end
