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
      # inferred from the folder name
      Dir.pwd.split("/").last.gsub(/[^a-zA-Z0-9_]/, "-").squeeze("-")
    end

    def framework
      Jets::Framework.name
    end

    def package_type
      (framework == "rails") ? "image" : "zip"
    end
  end
end
