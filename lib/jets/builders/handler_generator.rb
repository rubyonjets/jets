require "fileutils"
require "erb"

# Example:
#
# Jets::Builders::HandlerGenerator.new(
#   "PostsController",
#   :create, :update
# )
class Jets::Builders
  class HandlerGenerator
    def initialize(path)
      @path = path
    end

    def generate
      deducer = Jets::Builders::Deducer.new(@path)

      # TODO: move CodeBuilder.tmp_app_root to a common level for HandlerGenerator and CodeBuilder
      tmp_app_root = "#{Jets.build_root}/#{CodeBuilder.tmp_app_root}"
      js_path = "#{tmp_app_root}/#{deducer.js_path}"
      FileUtils.mkdir_p(File.dirname(js_path))

      template_path = File.expand_path('../node-shim.js', __FILE__)
      result = Jets::Erb.result(template_path, deducer: deducer)

      IO.write(js_path, result)
    end

  end
end
