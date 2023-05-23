module Jets::Controller::Compat
  # Got most from AbstractController::Caching and ActionController::Caching
  module Caching
    extend ActiveSupport::Concern

    delegate :perform_caching, to: :class
    class_methods do
      def perform_caching
        Jets.config.controller.perform_caching
      end
    end
  end
end
