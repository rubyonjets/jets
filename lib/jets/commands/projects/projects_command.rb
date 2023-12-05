module Jets::Command
  class ProjectsCommand < Base # :nodoc:
    desc "projects", "List deployed projects"
    long_desc Help.text(:projects)
    paging_options.call
    def perform
      no_token_exit!
      resp = Jets::Api::Project.list(paging_params)
      check_for_error_message!(resp)

      data = resp["data"]
      if data.empty?
        $stderr.puts "No projects deployed yet."
      else
        show_items(data)
      end
    rescue Jets::Api::RequestError => e
      puts "WARNING: Unable to list projects. #{e.class}: #{e.message}"
    end

  private
    def show_items(items)
      presenter = CliFormat::Presenter.new
      presenter.header = ["Name"]
      items.each do |item|
        puts item["name"]
      end
    end
  end
end
