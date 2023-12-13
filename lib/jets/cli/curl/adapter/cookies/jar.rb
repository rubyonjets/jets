module Jets::CLI::Curl::Adapter::Cookies
  class Jar
    include Jets::Util::Logging

    def initialize(result, filename)
      @result, @filename = result, filename
    end

    def write_to_file
      cookies = @result[:cookies]
      if cookies.nil? || cookies.empty?
        log.debug "No cookies found in the result."
        return
      end

      File.open(@filename, "w") do |file|
        cookies.each do |cookie|
          file.puts("# HTTP Cookie File")
          file.puts("# Created by jets curl #{Jets::VERSION}")
          file.puts("# Date: #{Time.now}\n\n")
          file.puts("#{cookie}\n")
        end
      end

      log.debug "Cookies written to #{@filename}."
    end
  end
end
