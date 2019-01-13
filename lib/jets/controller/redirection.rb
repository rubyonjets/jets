class Jets::Controller
  module Redirection
    # redirect_to "/posts", :status => 301
    # redirect_to :action=>'atom', :status => 302
    def redirect_to(url, options={})
      unless url.is_a?(String)
        raise "redirect_to url parameter must be a String. Please pass in a string"
      end

      uri = URI.parse(url)
      # if no location.host, we been provided a relative host
      if !uri.host && actual_host
        url = "/#{url}" unless url.starts_with?('/')
        url = add_stage_name(url)
        redirect_url = actual_host + url
      else
        redirect_url = url
      end

      redirect_url = ensure_protocol(redirect_url)

      aws_proxy = Rendering::RackRenderer.new(self,
        status: options[:status] || 302,
        headers: { "Location" => redirect_url },
        body: "",
        isBase64Encoded: false,
      )
      resp = aws_proxy.render
      # redirect is a type of rendering
      @rendered = true
      @rendered_data = resp
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
