class Jets::CLI::Release
  class Info < History
    rescue_api_error

    def run
      release = get(@options[:version])

      release_fields = %w[
        version
        status
        created_at
        message
        deploy_user
        jets_env
        jets_extra
        jets_version
        jets_remote
        ruby_version
        region
        docker_image
        zip_location
        git_branch
        git_sha
        git_url
        git_message
      ].map(&:to_sym)
      data = release_fields.map do |field|
        # special cases for values
        value = if field == :created_at
          pretty_time(release[:created_at])
        else
          release[field]
        end

        label = field.to_s.titleize
        [label, value]
      end

      release.endpoints.each do |endpoint|
        name = endpoint[:name].titleize
        data << [name, endpoint[:url]]
      end

      warn Jets.project.namespace.color(:green)
      presenter = CliFormat::Presenter.new(@options)
      presenter.empty_message = "Release not found for: #{Jets.project.namespace}"
      data.each do |row|
        presenter.rows << row
      end
      presenter.show
    end

    def get(version = nil)
      version ||= "latest"
      Jets::Api::Release.retrieve(version)
    end
  end
end
