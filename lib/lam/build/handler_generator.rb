require "fileutils"
require "erb"

class Lam::Build
  class HandlerGenerator
    # Lam::Build::HandlerGenerator.new(
    #   "PostsController",
    #   :create, :update
    # )
    def initialize(class_name, *methods)
      @class_name = class_name
      @methods = methods
    end

    def run
      js_path = "#{Lam.root}handlers/#{process_type}/#{module_name}.js"
      FileUtils.mkdir_p(File.dirname(js_path))

      template_path = File.expand_path('../templates/handler.js', __FILE__)
      template = IO.read(template_path)

      # Set used ERB variables:
      @process_type = process_type
      @functions = @methods.map do |m|
        {
          name: m,
          handler: handler(m)
        }
      end
      puts "generating #{js_path}"
      result = ERB.new(template, nil, "-").result(binding)
      IO.write(js_path, result)
    end

    def process_type
      @class_name.underscore.split('_').last.pluralize
    end

    def handler(method)
      "handlers/#{process_type}/#{module_name}.#{method}"
    end

    def module_name
      @class_name.sub(/Controller$/,'').underscore
    end
  end
end
