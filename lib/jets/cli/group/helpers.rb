module Jets::CLI::Group
  module Helpers
    extend Memoist

    def class_name
      name.camelize
    end

    def underscore_name
      name.underscore
    end

    def init_project_name
      Jets.project.name # inferred from the folder name
    end

    def framework
      Jets::CLI::Init::Detect.new.framework
    end
    memoize :framework

    def package_type
      (framework == "rails") ? "image" : "zip"
    end
  end
end
