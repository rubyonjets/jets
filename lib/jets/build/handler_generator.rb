require "fileutils"
require "erb"

# Example:
#
# Jets::Build::HandlerGenerator.new(
#   "PostsController",
#   :create, :update
# )
class Jets::Build
  class HandlerGenerator
    def initialize(path)
      @path = path
    end

    def generate
      Jets.boot

      deducer = Jets::Build::Deducer.new(@path)

      js_path = "#{Jets.root}#{deducer.js_path}"
      FileUtils.mkdir_p(File.dirname(js_path))

      template_path = File.expand_path('../node-shim.js', __FILE__)
      result = Jets::Erb.result(template_path, deducer: deducer)

      IO.write(js_path, result)
    end

  end
end
