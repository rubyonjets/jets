require "fileutils"
require "erb"

class Lam::Build
  class HandlerGenerator
    # handler_info:
    #   {:handler=>"handlers/controllers/posts.create",
    #    :js_path=>"handlers/controllers/posts.js",
    #    :js_method=>"create"}
    def initialize(handler_info)
      @handler_info = handler_info
      @handler = handler_info[:handler]
      @js_path = handler_info[:js_path]
      @js_method = handler_info[:js_method]
    end

    def generate
      js_path = "#{Lam.root}#{@js_path}"
      FileUtils.mkdir_p(File.dirname(js_path))

      template_path = File.expand_path('../templates/handler.js', __FILE__)
      template = IO.read(template_path)

      # Important ERB variables with examples:
      #   @handler - handlers/controllers/posts.create
      #   @process_type - controller
      @process_type = @handler.split('/')[1].singularize
      result = ERB.new(template, nil, "-").result(binding)
      IO.write(js_path, result)
      # FileUtils.cp(template_path, js_path)
    end
  end
end
