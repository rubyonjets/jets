class Jets::Controller
  module ForgeryProtection
    extend ActiveSupport::Concern

    included do
      config = Jets.config
      default_protect_from_forgery = config.dig(:controllers, :default_protect_from_forgery)
      if default_protect_from_forgery.nil? && config.mode == "html" || default_protect_from_forgery # true
        protect_from_forgery
      end
    end

    class_methods do
      def protect_from_forgery(options = {})
        before_action :verify_authenticity_token, options
      end

      def skip_forgery_protection
        skip_before_action :verify_authenticity_token
      end

      def forgery_protection_enabled?
        # Example:
        #
        #    before_actions [[:verify_authenticity_token, {}], [:set_post, {:only=>[:show, :edit, :update, :delete]}
        #
        before_actions.map { |a| a[0] }.include?(:verify_authenticity_token)
      end
    end

    # Instance methods
    def verify_authenticity_token
      return true if Jets.env.test? || request.get? || request.head?

      token = session[:authenticity_token]
      verified = !token.nil? && (token == params[:authenticity_token] || token == request.headers["x-csrf-token"])

      unless verified
        raise Error::InvalidAuthenticityToken
      end
    end
  end
end
