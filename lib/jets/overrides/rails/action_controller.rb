# frozen_string_literal: true

ActiveSupport.on_load :action_controller do
  class ActionController::Base
    class << self
      def _prefixes
        @@_prefixes
      end
      def _prefixes=(v)
        @@_prefixes = v
      end
    end
  end
end
