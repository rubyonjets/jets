require "fileutils"
require "erb"

# Example:
#
# Jets::Builders::HandlerGenerator.new(
#   "PostsController",
#   :create, :update
# )
module Jets::Builders
  class HandlerGenerator
    def self.build!
      new.build
    end

    def build
      generate_data_yaml
      app_ruby_shims
      poly_shims
      shared_shims
      internal_shims
    end

    # The handlers/data.yml is used by the shims
    def generate_data_yaml
      vars = Jets::Builders::ShimVars::Base.new
      data = {
        "s3_bucket" => vars.s3_bucket
      }
      data["rack_zip"] = vars.rack_zip if vars.rack_zip

      content = YAML.dump(data)
      path = "#{tmp_code}/handlers/data.yml"
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, content)
    end

    def app_ruby_shims
      app_files.each do |path|
        # Generates one shim for each app class: controller, job, etc
        vars = Jets::Builders::ShimVars::App.new(path)
        if path.include?('app/functions')
          copy_simple_function(path)
        else
          generate_handler(vars)
        end
      end
    end

    # source_path: app/functions/simple.rb
    def copy_simple_function(source_path)
      # Handler: handlers/controllers/posts_controller.handle
      dest_path = source_path.sub('app/functions', 'handlers/functions')
      FileUtils.mkdir_p(File.dirname(dest_path))
      FileUtils.cp(source_path, dest_path)
    end

    def app_files
      Jets::Commands::Build.app_files
    end

    def poly_shims
      missing = []

      app_files.each do |path|
        vars = Jets::Builders::ShimVars::App.new(path)
        poly_tasks = vars.klass.tasks.select { |t| t.lang != :ruby }
        poly_tasks.each do |task|
          source_path = get_source_path(path, task)
          if File.exist?(source_path)
            native_function(path, task)
          else
            missing << source_path
          end
        end

        unless missing.empty?
          puts "ERROR: Missing source files. Please make sure these source files exist or remove their declarations".color(:red)
          puts missing
          exit 1
        end
      end
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

    def internal_shims
      jets_base_path if Jets.custom_domain?
      s3_bucket_config if Jets.s3_event?
    end

    def jets_base_path
      copy_function_template("functions/jets/base_path.rb", stage_name: Jets::Resource::ApiGateway::Deployment.stage_name)
    end

    def s3_bucket_config
      copy_function_template("shared/functions/jets/s3_bucket_config.rb")
    end

    # Copy code from internal folder to materialized app code
    def copy_function_template(path, vars={})
      internal = File.expand_path("../internal", File.dirname(__FILE__))
      src = "#{internal}/app/#{path}"
      result = Jets::Erb.result(src, vars)
      dest = "#{tmp_code}/handlers/#{path}"
      FileUtils.mkdir_p(File.dirname(dest))
      IO.write(dest, result)
    end

    # app/shared/functions/kevin.py => /tmp/jets/demo/app_root/handlers/shared/functions/kevin.py
    def copy_source_as_handler(fun)
      return if fun.internal?

      source_path = fun.source_file
      unless source_path
        attributes = fun.template.values.first
        function_name = attributes['Properties']['FunctionName']
        puts "WARN: missing source file for: '#{function_name}' function".color(:yellow)
        return
      end

      dest_path = "#{tmp_code}/#{fun.handler_dest}"
      FileUtils.mkdir_p(File.dirname(dest_path))
      FileUtils.cp(source_path, dest_path)
    end

    def get_source_path(original_path, task)
      folder = original_path.sub(/\.rb$/,'')
      lang_folder = "#{folder}/#{task.lang}"
      root = Jets.root unless original_path.include?("lib/jets/internal")
      "#{root}/#{lang_folder}/#{task.meth}#{task.lang_ext}"
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
      # Cant use native_function because that requires task. Just re-implement
      dest_path = fun.handler_dest
      source_path = dest_path.sub(/^handlers/,'app')
      FileUtils.mkdir_p(File.dirname(dest_path))
      FileUtils.cp(source_path, dest_path)
    end

    def common_base_shim
      vars = Jets::Builders::ShimVars::Base.new
      result = evaluate_template("shim.js", vars)
      dest = "#{tmp_code}/handlers/shim.js"
      FileUtils.mkdir_p(File.dirname(dest))
      IO.write(dest, result)
    end

    def generate_handler(vars)
      result = evaluate_template("handler.rb", vars)
      dest = "#{tmp_code}/#{vars.dest_path}"
      FileUtils.mkdir_p(File.dirname(dest))
      IO.write(dest, result)
    end

    def evaluate_template(template_file, vars)
      template_path = File.expand_path("../templates/#{template_file}", __FILE__)
      Jets::Erb.result(template_path, vars: vars)
    end

    # TODO: move CodeBuilder.tmp_code to a common level for HandlerGenerator and CodeBuilder
    def tmp_code
      "#{Jets.build_root}/#{CodeBuilder.tmp_code}"
    end
  end
end
