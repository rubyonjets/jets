class Jets::CLI
  class Projects < Base
    rescue_api_error

    def run
      resp = Jets::Api::Project.list(paging_params)
      present(resp[:data])
      paginate(resp)
    end

    private

    def present(items)
      presenter = CliFormat::Presenter.new(@options)
      presenter.empty_message = "No projects found"
      items.each do |item|
        presenter.rows << [item[:name]]
      end
      presenter.show
    end
  end
end
