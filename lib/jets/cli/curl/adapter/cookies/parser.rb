module Jets::CLI::Curl::Adapter::Cookies
  class Parser
    def initialize(cookie_string)
      @cookie_string = cookie_string
    end

    def parse
      if @cookie_string.include?("=")
        parse_inline_cookies
      else
        parse_cookies_from_file
      end
    end

    private

    def skip_line?(line)
      line.empty? || line.start_with?("#")
    end

    def parse_inline_cookies
      cookies = []

      @cookie_string.split(";").each do |cookie|
        cookie = cookie.strip
        cookies << cookie unless skip_line?(cookie)
      end

      cookies
    end

    def parse_cookies_from_file
      cookies = []

      if File.exist?(@cookie_string)
        File.open(@cookie_string, "r").each_line do |line|
          line = line.chomp.strip
          cookies << line unless skip_line?(line)
        end
      else
        warn "Error: File '#{@cookie_string}' not found."
        exit 1
      end

      cookies
    end
  end
end
