class Jets::CLI::Ci
  class Info < Base
    include Jets::AwsServices

    def run
      resp = codebuild.batch_get_projects(names: [project_name])
      project = resp.projects.first
      present(project)
    end

    private

    def present(project)
      presenter = CliFormat::Presenter.new(@options)
      presenter.empty_message = "Project not found: #{project_name}"

      data = if project.nil?
        []
      else
        [
          ["Name", project.name],
          ["Arn", project.arn],
          ["Description", project.description],
          ["Service Role", project.service_role],
          ["Source", project.source.type],
          ["Environment", project.environment.type],
          ["Compute Type", project.environment.compute_type],
          ["Image", project.environment.image],
          ["Timeout", "#{project.timeout_in_minutes} minutes"],
          ["Created", project.created]
        ]
      end

      data.each do |row|
        presenter.rows << row
      end
      presenter.show
    end
  end
end
