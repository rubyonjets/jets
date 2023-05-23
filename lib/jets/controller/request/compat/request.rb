module Jets::Controller::Request::Compat
  # Based on ActionDispatch::Request class
  module Request
    extend Memoist

    ENV_METHODS = %w[ AUTH_TYPE GATEWAY_INTERFACE
      PATH_TRANSLATED REMOTE_HOST
      REMOTE_IDENT REMOTE_USER REMOTE_ADDR
      SERVER_NAME SERVER_PROTOCOL
      ORIGINAL_SCRIPT_NAME

      HTTP_ACCEPT HTTP_ACCEPT_CHARSET HTTP_ACCEPT_ENCODING
      HTTP_ACCEPT_LANGUAGE HTTP_CACHE_CONTROL HTTP_FROM
      HTTP_NEGOTIATE HTTP_PRAGMA HTTP_CLIENT_IP
      HTTP_X_FORWARDED_FOR HTTP_ORIGIN HTTP_VERSION
      HTTP_X_CSRF_TOKEN HTTP_X_REQUEST_ID HTTP_X_FORWARDED_HOST
      ].freeze

    ENV_METHODS.each do |env|
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        # frozen_string_literal: true
        def #{env.delete_prefix("HTTP_").downcase}  # def accept_charset
          get_header "#{env}"                       #   get_header "HTTP_ACCEPT_CHARSET"
        end                                         # end
      METHOD
    end

    LOCALHOST   = Regexp.union [/^127\.\d{1,3}\.\d{1,3}\.\d{1,3}$/, /^::1$/, /^0:0:0:0:0:0:0:1(%.*)?$/]

    def session
      key = ActionDispatch::Request::Session::ENV_SESSION_KEY
      session = env[key]
      if session.nil? # controller dispatch! does not go through middleware
        # mock session that is disabled
        session = ActionDispatch::Request::Session.new(nil, self, enabled: false)
      end
      session
    end

    def session=(session) # :nodoc:
      ActionDispatch::Request::Session.set self, session
    end

    def session_options=(options)
      ActionDispatch::Request::Session::Options.set self, options
    end

    def reset_session
      session.destroy
    end

    def headers
      top_level_headers.merge(http_headers)
    end

    def http_headers
      Hash[*env.select {|k,v| k.start_with? 'HTTP_'}
        .collect {|k,v| [k.sub(/^HTTP_/, ''), v]}
        .collect {|k,v| [k.split('_').collect(&:capitalize).join('-'), v]}
        .sort
        .flatten]
    end

    # These are not part of a Rails headers but believe
    # they make sense to add as it feel like expected behavior.
    def top_level_headers
      hash = {
        "Host" => env["HTTP_HOST"],
        "Content-Type" => env["CONTENT_TYPE"],
        "Content-Length" => env["CONTENT_LENGTH"],
      }
      hash.delete_if { |k, v| v.nil? }
      hash
    end

    # Returns the lowercase name of the HTTP server software.
    def server_software
      (get_header("SERVER_SOFTWARE") && /^([a-zA-Z]+)/ =~ get_header("SERVER_SOFTWARE")) ? $1.downcase : nil
    end

    # Returns the authorization header regardless of whether it was specified directly or through one of the
    # proxy alternatives.
    def authorization
      get_header("HTTP_AUTHORIZATION")   ||
      get_header("X-HTTP_AUTHORIZATION") ||
      get_header("X_HTTP_AUTHORIZATION") ||
      get_header("REDIRECT_X_HTTP_AUTHORIZATION")
    end

    # True if the request came from localhost, 127.0.0.1, or ::1.
    def local?
      LOCALHOST.match?(remote_addr) && LOCALHOST.match?(remote_ip)
    end

    def controller_class_for(name)
      controller_param = name.underscore
      const_name = controller_param.camelize << "Controller"
      const_name.constantize
    end

    def request_method_symbol
      request_method.downcase.to_sym
    end
    alias method_symbol request_method_symbol

    # Returns the IP address of client as a +String+,
    # usually set by the RemoteIp middleware.
    def remote_ip
      @remote_ip ||= (get_header("action_dispatch.remote_ip") || ip).to_s
    end

    def remote_ip=(remote_ip)
      @remote_ip = nil
      set_header "action_dispatch.remote_ip", remote_ip
    end

    # Needed when action_view.preload_links_header = true
    # Rails 6.1 defaults
    def send_early_hints(links)
      return unless env["rack.early_hints"]

      env["rack.early_hints"].call(links)
    end
  end
end
