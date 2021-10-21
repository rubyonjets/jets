class Jets::Controller
  module Redirection
    # redirect_to "/posts", :status => 301
    # redirect_to :action=>'atom', :status => 302
    def redirect_to(url, options={})
      unless url.is_a?(String)
        raise "redirect_to url parameter must be a String. Please pass in a string"
      end

      redirect_url = add_stage(url)
      redirect_url = ensure_protocol(redirect_url)

      default = {
        headers: { "Location" => redirect_url },
        isBase64Encoded: false,
      }
      if request.xhr?
        options[:content_type] ||= "application/json"
        options[:status] ||= 200
        options[:body] ||= JSON.dump(success: true, location: redirect_url)
      else
        options[:status] ||= 302
        options[:body] ||= ""
      end
      Jets.logger.info("redirect_to options #{options}")
      options = default.merge(options)

      aws_proxy = Rendering::RackRenderer.new(self, options)
      resp = aws_proxy.render
      # redirect is a type of rendering
      @rendered = true
      @rendered_data = resp
    end

    def redirect_back(fallback_location: '/')
      location = request.headers["referer"] || fallback_location
      redirect_to(location)
    end

    def ensure_protocol(url)
      return url if url.starts_with?('http')

      # annoying but the request payload is different with localhost/rack vs
      # api gateway
      # check out:
      #   spec/fixtures/dumps/api_gateway/posts/create.json
      #   spec/fixtures/dumps/rack/posts/create.json
      protocol = if headers["x-forwarded-proto"] # API Gateway
          headers["x-forwarded-proto"]
        elsif headers["origin"] # Rack / localhost
          URI.parse(headers["origin"]).scheme
        else
          "http" # fallback. Capybara / Selenium tests
        end

      raise "Invalid protocol #{protocol}" unless protocol.starts_with?('http')

      "#{protocol}://#{url}"
    end
  end
end
