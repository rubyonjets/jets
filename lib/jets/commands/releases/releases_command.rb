module Jets::Command
  class ReleasesCommand < Base # :nodoc:
    desc "history", "List deploy history"
    long_desc Help.text(:history)
    paging_options(order: 'desc').call
    def perform
      Release.new(options.merge(paging_params)).list
    end
  end

  class Release
    include Jets::Command::ApiHelpers
    def initialize(options={})
      @options = options
    end

    def list
      no_token_exit!
      resp = Jets::Api::Stack.retrieve(:current)
      if resp["error"] == "not_found"
        puts "No release history. Stack not found: #{Jets.project_namespace}"
        # Return early and avoid calling Jets::Api::Release.list if stack not found
        # Note: Jets::Api::Release.list also checks for no stack found
        return
      end

      name = "#{resp['name']} #{resp['location']}"
      resp = Jets::Api::Release.list(@options)
      check_for_error_message!(resp) # can also return "Stack not found #{name}" message
      data = resp["data"]
      if data.empty?
        $stderr.puts "No releases found for stack: #{name}"
      else
        $stderr.puts "Releases for stack: #{name}"
        show_items(data)
      end
    rescue Jets::Api::RequestError => e
      puts "ERROR: Unable to list history. #{e.class}: #{e.message}"
    end

    def show_items(items)
      presenter = CliFormat::Presenter.new
      presenter.header = ["Version", "Status", "Released At", "Message"]
      items.each do |item|
        version = item["version"]
        status = item["stack_status"]
        released_at = item["pretty_created_at"] || item["created_at"]
        message = item["message"] || "Deployed"

        row = [version, status, format_time(released_at), message]
        presenter.rows << row
      end
      presenter.show
    end

    def format_time(string)
      if string.include?("ago") # IE: 5 minutes ago
        string
      else
        time = Time.parse(string)
        time.in_time_zone(Time.zone)
      end
    end

    def get(version)
      resp = Jets::Api::Release.retrieve(version)
      check_for_error_message!(resp)
    rescue Jets::Api::RequestError => e
      puts "ERROR: Unable to get history. #{e.class}: #{e.message}"
    end
  end
end
