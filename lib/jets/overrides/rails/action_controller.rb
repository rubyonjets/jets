ActiveSupport.on_load :action_controller do
  class ActionController::Base
    class << self
      @@_prefixes = nil
      def _prefixes
        @@_prefixes
      end
      def _prefixes=(v)
        @@_prefixes = v
      end
    end
  end
end
