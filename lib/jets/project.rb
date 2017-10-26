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
    OpenStruct.new(
      project_name: "proj", # shouldnt really be a default here
      env: ENV['JETS_ENV'] || 'dev', # shouldnt really be a default here
      timeout: 30,
      runtime: "nodejs6.10",
      memory_size: 1536
    )
  end
end
