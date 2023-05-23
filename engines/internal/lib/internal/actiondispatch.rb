require "active_support/messages/rotation_configuration"

module Jets::Internal
  # Reference: https://github.com/rails/rails/blob/master/actiondispatch/lib/action_dispatch/railtie.rb
  class Actiondispatch < ::Jets::Turbine
    config.action_dispatch = ActiveSupport::OrderedOptions.new
    config.action_dispatch.x_sendfile_header = nil
    config.action_dispatch.ip_spoofing_check = true
    config.action_dispatch.show_exceptions = true
    config.action_dispatch.tld_length = 1
    config.action_dispatch.ignore_accept_header = false
    config.action_dispatch.rescue_templates = {}
    config.action_dispatch.rescue_responses = {}
    config.action_dispatch.default_charset = nil
    config.action_dispatch.rack_cache = false
    config.action_dispatch.http_auth_salt = "http authentication"
    config.action_dispatch.signed_cookie_salt = "signed cookie"
    config.action_dispatch.encrypted_cookie_salt = "encrypted cookie"
    config.action_dispatch.encrypted_signed_cookie_salt = "signed encrypted cookie"
    config.action_dispatch.authenticated_encrypted_cookie_salt = "authenticated encrypted cookie"
    config.action_dispatch.use_authenticated_cookie_encryption = false
    config.action_dispatch.use_cookies_with_metadata = false
    config.action_dispatch.perform_deep_munge = true
    config.action_dispatch.request_id_header = "X-Request-Id"
    config.action_dispatch.return_only_request_media_type_on_content_type = true
    config.action_dispatch.log_rescued_responses = true

    config.action_dispatch.default_headers = {
      "X-Frame-Options" => "SAMEORIGIN",
      "X-XSS-Protection" => "1; mode=block",
      "X-Content-Type-Options" => "nosniff",
      "X-Download-Options" => "noopen",
      "X-Permitted-Cross-Domain-Policies" => "none",
      "Referrer-Policy" => "strict-origin-when-cross-origin"
    }

    config.action_dispatch.cookies_rotations = ActiveSupport::Messages::RotationConfiguration.new
  end
end
