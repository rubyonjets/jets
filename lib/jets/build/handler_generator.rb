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
      # find_deducer_class exames: ControllerDeducer or JobDeducer
      deducer_class = find_deducer_class
      deducer = deducer_class.new(@path)

      js_path = "#{Jets.root}#{deducer.js_path}"
      FileUtils.mkdir_p(File.dirname(js_path))

      @deducer = deducer # Required ERB variablefor node-shim.js template
      template_path = File.expand_path('../node-shim.js', __FILE__)
      result = Jets::Erb.result(template_path)

      IO.write(js_path, result)
    end

    # base on the path a different deducer will be used
    def find_deducer_class
      # process_class example: Jets::Build::Deducer::ControllerDeducer
      process_class = @path.split('/')[1].classify # Controller or Job
      "Jets::Build::Deducer::#{process_class}Deducer".constantize
    end

  end
end
