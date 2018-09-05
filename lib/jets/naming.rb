# This class groups the naming in one place.
# Some naming is for CloudFormation
# Some are for the Build process
class Jets::Naming
  # Mainly used by build.rb
  class << self
    def template_path(app_class)
      underscored = app_class.to_s.underscore.gsub('/','-')
      "#{template_path_prefix}-#{underscored}.yml"
    end

    def template_path_prefix
      "#{Jets.build_root}/templates/#{Jets.config.project_namespace}"
    end

    # consider moving these methods into cfn/builder/helpers.rb or that area.
    def parent_template_path
      "#{template_path_prefix}.yml"
    end

    # consider moving these methods into cfn/builder/helpers.rb or that area.
    def api_gateway_template_path
      "#{template_path_prefix}-api-gateway.yml"
    end

    def api_deployment_template_path
      "#{template_path_prefix}-api-deployment.yml"
    end

    def parent_stack_name
      File.basename(parent_template_path, ".yml")
    end

    def gateway_api_name
      "#{Jets.config.project_namespace}"
    end

    def code_s3_key
      md5_zipfile = File.basename(md5_code_zipfile)
      "jets/code/#{md5_zipfile}"
    end

    # build was already ran and that a file that contains the md5 path exists
    # at Jets.build_root/code/current-md5-filename.txt
    #
    # md5_code_zipfile: /tmp/jets/demo/code/code-2e0e18f6.zip
    def md5_code_zipfile
      path = "#{Jets.build_root}/code/current-md5-filename.txt"
      File.exist?(path) ? IO.read(path) : "current-md5-filename-doesnt-exist"
    end
    # The current-md5-filename.txt gets created as a part of CodeBuilder's build
    # process.
    # And is required to be used much later for cfn/ship and base_child_builder
    # They need set an s3_key which requires the md5_zip_dest.
    # It is a pain to pass this all the way up from the
    # CodeBuilder class.
    # We store the "/tmp/jets/demo/code/code-a8a604aa.zip" into a
    # file that can be read from any places where this is needed.
    # Can also just generate a "fake file" for specs
  end
end
