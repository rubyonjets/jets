# Implemented this way to remind us how Rails implemented it.
# Otherwise, would have just added another module to the include chain in
# Jets::Controller::Base.
module JetsTurbines
  module Helpers
    def inherited(klass)
      super
      return unless klass.respond_to?(:helpers_path=) # IE: ActionMailer does not respond to helpers_path=

      paths = ActionController::Helpers.helpers_path
      klass.helpers_path = paths

      if klass.superclass == Jets::Controller::Base
        klass.helper :all
      end
    end
  end
end
