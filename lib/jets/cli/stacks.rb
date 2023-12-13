class Jets::CLI
  class Stacks < Base
    rescue_api_error

    def run
      params = paging_params.merge(options)
      resp = Jets::Api::Stack.list(params)
      log.info stacks_for_message
      present(resp[:data])
      paginate(resp)
    end

    private

    def stacks_for_message
      if options[:all_projects]
        "Stacks for all projects:"
      else
        "Stacks for project: #{Jets.project.name}"
      end
    end

    def present(items)
      presenter = CliFormat::Presenter.new(@options)
      presenter.empty_message = "No stacks found"
      items.each do |item|
        row = "#{item[:name]} #{item[:location]}"
        presenter.rows << [row]
      end
      presenter.show
    end
  end
end
