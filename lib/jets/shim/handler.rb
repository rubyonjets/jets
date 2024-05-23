module Jets::Shim
  class Handler
    include Jets::Util::Logging

    attr_reader :event, :context, :target
    def initialize(event, context = nil, target = nil)
      @event = event.deep_stringify_keys
      @context = context
      @target = target # IE: cool_event.party
    end

    def handle
      show_debug_shim_event
      adapter.handle
    end

    def adapter
      adapter_class = Adapter.const_get(adapter_name.to_s.camelize)
      log.info "jets shim adapter: #{adapter_name}" if ENV["JETS_DEBUG_SHIM"]
      adapter_class.new(event, context, target) # IE: Adapter::Apigw
    end

    protected

    def adapter_name
      Jets::Shim.config.adapter || infer_adapter
    end

    def infer_adapter
      adapters = %w[lambda apigw alb prewarm command event]
      adapters.each do |adapter_name|
        adapter_class = Adapter.const_get(adapter_name.to_s.camelize)
        return adapter_name if adapter_class.new(event, context, target).handle?
      end
      :fallback
    end

    def show_debug_shim_event
      self.class.show_debug_shim("jets shim event:", event)
    end

    class << self
      include Jets::Util::Logging

      # interface method used by Shim::Response::Base
      def show_debug_shim(message, payload)
        return unless ENV["JETS_DEBUG_SHIM"]

        log.info message
        # pretty mode is not useful on CloudWatch since it strips the surrounding spaces on each line
        # It's only useful for testing handlers locally
        if ENV["JETS_DEBUG_SHIM"] == "pretty"
          log.info JSON.pretty_generate(payload)
        else
          log.info JSON.dump(payload) # json one line
        end
      end
    end
  end
end
