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
      common_shim
      poly_shims
      app_ruby_shim
      shared_shims
    end

    def shared_shims
      Jets::Stack.subclasses.each do |subclass|
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
      unless source_path
        attributes = fun.template.values.first
        function_name = attributes['Properties']['FunctionName']
        puts "WARN: missing source file for: '#{function_name}' function".colorize(:yellow)
        return
      end

      dest_path = "#{tmp_code}/#{fun.handler_dest}"
      FileUtils.mkdir_p(File.dirname(dest_path))
      FileUtils.cp(source_path, dest_path)
    end

    def poly_shims
      missing = []

      vars = Jets::Builders::ShimVars::App.new(@path)
      poly_tasks = vars.klass.tasks.select { |t| t.lang != :ruby }
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
      dest_path = "#{tmp_code}/#{task.handler_path}"
      FileUtils.mkdir_p(File.dirname(dest_path))
      FileUtils.cp(source_path, dest_path)
    end

    def shared_ruby_shim(fun)
      vars = Jets::Builders::ShimVars::Shared.new(fun)
      generate_handler(vars)
    end

    # Generates one big node shim for a entire controller.
    def app_ruby_shim
      vars = Jets::Builders::ShimVars::App.new(@path)
      generate_handler(vars)
    end

    def common_shim
      vars = Jets::Builders::ShimVars::Base.new
      result = evaluate_template("node-shim.js", vars)
      dest = "#{tmp_code}/handlers/shim.js"
      IO.write(dest, result)
    end

    def generate_handler(vars)
      result = evaluate_template("node-handler.js", vars)
      dest = "#{tmp_code}/#{vars.js_path}"
      FileUtils.mkdir_p(File.dirname(dest))
      IO.write(dest, result)
    end

    def evaluate_template(template_file, vars)
      template_path = File.expand_path("../#{template_file}", __FILE__)
      Jets::Erb.result(template_path, vars: vars)
    end

    # TODO: move CodeBuilder.tmp_code to a common level for HandlerGenerator and CodeBuilder
    def tmp_code
      "#{Jets.build_root}/#{CodeBuilder.tmp_code}"
    end
  end
end
