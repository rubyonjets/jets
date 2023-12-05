module Jets::Command
  class StacksCommand < Base # :nodoc:
    desc "stacks", "List deployed stacks"
    long_desc Help.text(:stacks)
    paging_options.call
    option :all_projects, desc: "Show all stacks across all projects", type: :boolean, default: false
    def perform
      name = Jets.project_name
      no_token_exit!
      params = paging_params.merge(options)
      resp = Jets::Api::Stack.list(params)
      check_for_error_message!(resp)

      data = resp["data"]
      if data.empty?
        $stderr.puts "No stacks deployed yet: #{name}"
      else
        message = if options[:all_projects]
                    "Stacks for all projects:"
                  else
                    "Stacks for project: #{name}"
                  end
        $stderr.puts message
        show_items(data)
      end
    rescue Jets::Api::RequestError => e
      puts "WARNING: Unable to list stacks. #{e.class}: #{e.message}"
    end

  private
    def show_items(items)
      presenter = CliFormat::Presenter.new
      presenter.header = ["Name"]
      items.each do |item|
        puts "#{item['name']} #{item['location']}"
      end
    end
  end
end
