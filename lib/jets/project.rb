require 'ostruct'

# The Project default options.
# Overriden with config/project.yml
class Jets::Project
  class << self
    def method_missing(method_name)
      options = Jets::Project.new.options
      options[method_name.to_sym]
    end
  end

  # Defaults
  def options
    default_project_name = "proj"  # TODO: should probably prompt user for a
    # project name or validate a project name is configured in config/project.yml
    OpenStruct.new(
      project_name: default_project_name,
      env: ENV['JETS_ENV'] || 'dev', # shouldnt really be a default here
      timeout: 30,
      runtime: "nodejs6.10",
      memory_size: 1536
    )
  end
end
