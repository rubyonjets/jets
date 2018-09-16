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
      poly_shims
      app_ruby_shim
      shared_shims
    end

    def shared_shims
      Jets::Stack.subclasses.each do |subclass|
        pp subclass
        pp subclass.functions.size
        subclass.functions.each do |fun|
          if fun.lang.to_s == "ruby"
            shared_ruby_shim(fun)
          else
            copy_source_as_handler(fun)
          end
        end
      end
    end

    # app/shared/functions/kevin.py => /tmp/jets/demo/app_root/handlers/shared/functions/kevin.py
    def copy_source_as_handler(fun)
      source_path = fun.source_file
      dest_path = "#{tmp_app_root}/#{fun.handler_dest}"
      FileUtils.mkdir_p(File.dirname(dest_path))
      FileUtils.cp(source_path, dest_path)
    end

    def poly_shims
      missing = []

      deducer = Jets::Builders::Deducer.new(@path)
      poly_tasks = deducer.klass.tasks.select { |t| t.lang != :ruby }
      poly_tasks.each do |task|
        source_path = get_source_path(@path, task)
        if File.exist?(source_path)
          native_function(@path, task)
        else
          missing << source_path
        end
      end

      unless missing.empty?
        puts "ERROR: Missing source files. Please make sure these source files exist or remove their declarations".colorize(:red)
        puts missing
        exit 1
      end
    end

    def get_source_path(original_path, task)
      folder = original_path.sub(/\.rb$/,'')
      lang_folder = "#{folder}/#{task.lang}"
      root = Jets.root unless original_path.include?("lib/jets/internal")
      "#{root}#{lang_folder}/#{task.meth}#{task.lang_ext}"
    end

    # Builds and copies over the native source code: python or node
    def native_function(original_path, task)
      source_path = get_source_path(original_path, task)
      # Handler: handlers/controllers/posts_controller.handle
      dest_path = "#{tmp_app_root}/#{task.handler_path}"
      FileUtils.mkdir_p(File.dirname(dest_path))
      FileUtils.cp(source_path, dest_path)
    end

    def shared_ruby_shim(fun)
      puts "shared_ruby_shim #{fun}"
      deducer = Jets::Builders::SharedDeducer.new(fun)
      generate_shim(deducer)
    end

    # Generates one big node shim for a entire controller.
    def app_ruby_shim
      deducer = Jets::Builders::Deducer.new(@path)
      generate_shim(deducer)
    end

    def generate_shim(deducer)
      js_path = "#{tmp_app_root}/#{deducer.js_path}"
      FileUtils.mkdir_p(File.dirname(js_path))

      template_path = File.expand_path('../node-shim.js', __FILE__)
      result = Jets::Erb.result(template_path, deducer: deducer)

      IO.write(js_path, result)
    end

    # TODO: move CodeBuilder.tmp_app_root to a common level for HandlerGenerator and CodeBuilder
    def tmp_app_root
      "#{Jets.build_root}/#{CodeBuilder.tmp_app_root}"
    end
  end
end
