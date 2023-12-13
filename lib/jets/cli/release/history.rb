require "date"
require "tzinfo"

class Jets::CLI::Release
  class History < Base
    rescue_api_error

    def run
      resp = Jets::Api::Stack.retrieve(:current)

      name = "#{resp[:name]} #{resp[:location]}"
      resp = Jets::Api::Release.list(@options)

      data = resp[:data]
      if data.empty?
        log.info "No releases found for stack: #{name}"
      else
        log.info "Releases for stack: #{name}"
        show_items(data)
        paginate(resp)
      end
    end

    def show_items(items)
      presenter = CliFormat::Presenter.new(@options)
      header = ["Version", "Status", "Released At", "Message"]
      header << "Git Sha" if @options[:sha]
      presenter.header = header
      items.each do |item|
        version = item[:version]
        status = item[:stack_status]
        released_at = item[:pretty_created_at] || item[:created_at]
        message = item[:message] || "Deployed"
        message = message[0..50]

        row = [version, status, format_time(released_at), message]
        if @options[:sha]
          sha = item[:git_sha].to_s[0..7] if item[:git_sha]
          row << sha
        end
        presenter.rows << row
      end
      presenter.show
    end

    def format_time(string)
      if string.include?("ago") # IE: 5 minutes ago
        string
      else
        utc = DateTime.parse(string)

        tz_override = ENV["JETS_TZ"] # IE: America/Los_Angeles
        local = if tz_override
          tz = TZInfo::Timezone.get(tz_override)
          tz.utc_to_local(utc)
        else
          utc.new_offset(DateTime.now.offset) # local time
        end

        if tz_override
          local.strftime("%b %-d, %Y %-l:%M:%S%P")
        else
          local.strftime("%b %-d, %Y %H:%M:%S")
        end
      end
    end
  end
end
