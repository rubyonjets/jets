require "date"
require "tzinfo"

class Jets::CLI::Release
  class History < Base
    include Jets::Util::FormatTime
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
        released_at = item[:created_at]
        message = item[:message] || "Deployed"
        message = message[0..50]

        row = [version, status, pretty_time(released_at), message]
        if @options[:sha]
          sha = item[:git_sha].to_s[0..7] if item[:git_sha]
          row << sha
        end
        presenter.rows << row
      end
      presenter.show
    end
  end
end
