require "aws-sdk-core"
require "open-uri"

module Jets::Api
  class Client
    extend Memoist
    include Jets::Api::Error::Handlers
    include Jets::Util::Logging

    @@max_retries = 3 # 4 attempts total

    def execute_request(klass, path, data = {}, headers = {})
      data = global_params(path).merge(data)
      if klass == Net::HTTP::Get
        path = path_with_query(path, data)
        data = {}
      end

      url = url(path)
      req = build_request(klass, url, data, headers)
      http_resp = http_request(req)

      resp = Jets::Api::Response.new(http_resp)
      puts_debug_resp(url, resp)

      if handle_as_error?(resp.http_status)
        handle_error_response!(resp)
      end

      # Always translate Json Response to Ruby Hash
      resp.data # JSON.parse(@http_resp.body) => Ruby hash
    end

    def build_request(klass, url, data = {}, headers = {})
      req = klass.new(url) # url includes query string and uri.path does not, must used url
      set_headers!(req)
      if [Net::HTTP::Delete, Net::HTTP::Patch, Net::HTTP::Post, Net::HTTP::Put].include?(klass)
        text = JSON.dump(data)
        puts_debug_request(data)
        req.body = text
        req.content_length = text.bytesize
        req.content_type = "application/json"
      end
      req
    end

    NETWORK_ERRORS = [
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      Errno::ETIMEDOUT,
      Jets::Api::Error::Maintenance,
      Jets::Api::Error::ServiceUnavailable, # mimic 503 Net::HTTPServiceUnavailable
      Net::HTTPServiceUnavailable, # cannot rescue. Unsure why
      Net::OpenTimeout,
      Net::ReadTimeout,
      OpenSSL::SSL::SSLError,
      OpenURI::HTTPError,
      SocketError
    ]

    def http_request(req, retries = 0)
      resp = http.request(req) # send request. returns raw response
      reraise_error_from_503!(req, resp)
      resp
    rescue *NETWORK_ERRORS => error
      if retries < @@max_retries
        delay = 2**retries
        log.debug "Error: #{error.class} #{error.message} retrying after #{delay} seconds..."
        sleep delay
        retries += 1
        retry
      elsif error.is_a?(Jets::Api::Error::Maintenance)
        # The Jets API is under maintenance
        log.info error.message # message provides context already
        exit 1
      else
        message = "Unexpected error #{error.class.name} communicating with the Jets API. "
        message += " Request was attempted #{retries + 1} times."
        raise Jets::Api::Error::Connection, message + "\nNetwork error: #{error.message}"
      end
    end

    # For some reason, rescue Net::HTTPServiceUnavailable is not being caught.
    # So mimic it.
    # Can reproduce by using local Jets API service and not starting it up
    def reraise_error_from_503!(req, resp)
      return unless resp.code == "503" # Service Unavailable

      if maintenance_mode?(resp.body)
        payload = JSON.parse(resp.body)
        raise Jets::Api::Error::Maintenance, payload["message"]
      else
        raise Jets::Api::Error::ServiceUnavailable, "Request #{req.path}"
      end
    end

    def maintenance_mode?(body)
      payload = JSON.parse(body)
      payload["status"] == "maintenance"
    rescue JSON::ParserError
      false
    end

    def http
      uri = URI(endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = http.read_timeout = 30
      http.use_ssl = true if uri.scheme == "https"
      http
    end
    memoize :http

    def global_params(path)
      args = ARGV.reject { |arg| arg.include?("-") }
      params = {
        account: Jets.aws.account,
        command: command,
        jets_env: Jets.env.to_s,
        jets_extra: Jets.extra,
        jets_go_version: ENV["JETS_GO_VERSION"],
        jets_remote_version: ENV["JETS_REMOTE_VERSION"],
        jets_version: Jets::VERSION,
        region: Jets.aws.region,
        ruby_version: RUBY_VERSION
      }
      if Jets::Thor::ProjectCheck.new(args).project? || command == "delete"
        params[:project_namespace] = Jets.project.namespace
        params[:project_name] = Jets.project.name
      end

      params.delete_if { |k, v| v.nil? }
      params
    end

    def command
      args = ARGV.reject { |arg| arg.include?("-") }
      if args.first == "rollback" # IE: jets rollback 8
        args.first
      else
        args.join(":")
      end
    end

    # API does not include the /. IE: https://app.terraform.io/api/v2
    def url(path)
      path = "/#{path}" unless path.starts_with?("/")
      "#{endpoint}#{path}"
    end

    def path_with_query(path, query = {})
      return path if query.empty?
      separator = path.include?("?") ? "&" : "?"
      "#{path}#{separator}#{query.to_query}"
    end

    def set_headers!(req, headers = {})
      headers.each { |k, v| req[k] = v }
      req["Authorization"] = api_key if api_key
      req["x-account"] = account if account
      req["x-session"] = session if session
      req
    end

    # 422 Unprocessable Entity: Server understands the content type of the request entity, and
    # the syntax of the request entity is correct, but it was unable to process the contained
    # instructions.
    # TODO: remove? or rename to ha
    def processable?(http_code)
      http_code =~ /^2/ || http_code =~ /^4/
    end

    def session
      session_path = "#{ENV["HOME"]}/.jets/session.yml"
      if File.exist?(session_path)
        data = YAML.load_file(session_path)
        data["secret_token"]
      end
    end

    def api_key
      Jets::Api.api_key
    end

    def get(path, data = {})
      execute_request(Net::HTTP::Get, path, data)
    end

    def post(path, data = {})
      execute_request(Net::HTTP::Post, path, data)
    end

    def put(path, data = {})
      execute_request(Net::HTTP::Put, path, data)
    end

    def patch(path, data = {})
      execute_request(Net::HTTP::Patch, path, data)
    end

    def delete(path, data = {})
      execute_request(Net::HTTP::Delete, path, data)
    end

    def account
      sts.get_caller_identity.account
    rescue
      nil
    end
    memoize :account

    def sts
      Aws::STS::Client.new
    end
    memoize :sts

    def endpoint
      return ENV["JETS_API"] if ENV["JETS_API"]

      major = Jets::VERSION.split(".").first.to_i
      if major >= 6
        "https://api.rubyonjets.com/v2"
      else
        "https://api.rubyonjets.com/v1"
      end
    end
    memoize :endpoint

    def puts_debug_resp(url, resp)
      return unless ENV["JETS_DEBUG_API"]
      puts "API Response for url #{url}"
      begin
        puts JSON.pretty_generate(resp.data)
      rescue
        puts "Cannot JSON pretty_generate resp #{resp.inspect}"
        nil
      end
    end

    def puts_debug_request(data)
      return unless ENV["JETS_DEBUG_API"]
      log.info "POST data:"
      log.info JSON.pretty_generate(data)
    end
  end
end
