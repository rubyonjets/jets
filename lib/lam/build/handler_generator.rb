require "fileutils"

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
      FileUtils.cp(template_path, js_path)
      # FileUtils.touch(js_path)
    end
  end
end
