module Jets::Command
  class ReleasesCommand < Base # :nodoc:
    desc "releases", "List releases"
    long_desc Help.text(:releases)
    paging_options(order: 'desc').call
    option :sha, desc: "Show release git sha"
    def perform
      Release.new(options.merge(paging_params)).list
    end

    desc "releases:info", "View detailed information for a release"
    long_desc Help.text(:info)
    def info(version=nil)
      if version.nil?
        puts "ERROR: Must provide a version".color(:red)
        puts <<~EOL
          Example:

            jets releases:info 3
        EOL
        exit 1
      end
      Release.new(options.merge(version: version)).show
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
      puts "ERROR: Unable to list releases. #{e.class}: #{e.message}"
    end

    def show_items(items)
      presenter = CliFormat::Presenter.new
      header = ["Version", "Status", "Released At", "Message"]
      header << "Git Sha" if @options[:sha]
      presenter.header = header
      items.each do |item|
        version = item["version"]
        status = item["stack_status"]
        released_at = item["pretty_created_at"] || item["created_at"]
        message = item["message"] || "Deployed"
        message = message[0..50]

        row = [version, status, format_time(released_at), message]
        if @options[:sha]
          sha = item["git_sha"].to_s[0..7] if item["git_sha"]
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
        time = Time.parse(string)
        time.in_time_zone(Time.zone)
      end
    end

    def get(version)
      resp = Jets::Api::Release.retrieve(version)
      check_for_error_message!(resp)
    rescue Jets::Api::RequestError => e
      puts "ERROR: Unable to get release. #{e.class}: #{e.message}"
    end

    def show
      release = get(@options[:version])
      release_at = release['pretty_created_at'] || release['created_at']

      data = [
        ["Version", release['version']],
        ["Status", release['stack_status']],
        ["Released At", format_time(release_at)],
        ["Message", release['message']],
        ["User", release['deploy_user']],
        ["Jets Env", release['jets_env']],
        ["Jets Extra", release['jets_extra']],
        ["Jets Version", release['jets_version']],
        ["Ruby Version", release['ruby_version']],
        ["Region", release['region']],
        ["Git Branch", release['git_branch']],
        ["Git Sha", release['git_sha']],
        ["Git Url", release['git_url']],
        ["Git Message", release['git_message']],
      ]
      column1_width = data.map { |row| row[1].nil? ? 0 : row[0].to_s.length }.max
      column2_width = data.map { |row| row[1].nil? ? 0 : row[1].to_s.length }.max

      puts Jets.project_namespace.color(:green)
      data.each do |row|
        puts "#{row[0].ljust(column1_width)}   #{row[1]}" unless row[1].nil?
      end
    end
  end
end
