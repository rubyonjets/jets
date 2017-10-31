# Interface method:
#   def process_type
#     "controller"
#   end
#
# or:
#   def process_type
#     "job"
#   end
class Jets::Build::Deducer
  class BaseDeducer
    attr_reader :path
    def initialize(path)
      @path = path
    end

    def class_name
      @path.sub(%r{app/(\w+)/},'').sub('.rb','').classify # PostsController
    end

    # This gets called in the node shim js template
    def handler_for(method)
      regexp = Regexp.new("#{process_type.camelize}$") # process_type: controller or job
      module_name = class_name.sub(regexp, '').underscore # IE: posts (controller) or sleep (job)
      "handlers/#{process_type.pluralize}/#{module_name}.#{method}"
    end

    # Returns: "handlers/controllers/posts.js"
    def js_path
      @path.sub("app", "handlers").sub("_#{process_type}.rb", ".js")
    end

    # Used to show user where the generated files gets written to.
    # Returns: "/tmp/jets_build/templates/proj-dev-posts-controller.yml"
    def cfn_path
      stack_name = File.basename(@path, ".rb").dasherize
      stack_name = "#{Jets::Config.project_namespace}-#{stack_name}"
      "/tmp/jets_build/templates/#{stack_name}.yml"
    end
  end
end