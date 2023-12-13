require "active_support/core_ext/hash"
require "base64"

module Jets::Shim::Adapter
  class Base
    extend Memoist
    include Jets::Util::Logging

    attr_reader :event, :context, :target
    def initialize(event, context = nil, target = nil)
      @event = ActiveSupport::HashWithIndifferentAccess.new(event)
      @context = context
      @target = target # IE: cool_event.party
    end
  end
end
