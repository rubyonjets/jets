# This class groups the naming in one place.
# Some naming is for CloudFormation
# Some are for the Build process
class Jets::Naming
  # Mainly used by build.rb
  class << self
    def template_path(controller_class)
      underscored_controller = controller_class.to_s.underscore.gsub('/','-')
      "#{template_path_prefix}-#{underscored_controller}.yml"
    end

    # consider moving these methods into cfn/builder/helpers.rb or that area.
    def parent_template_path
      "#{template_path_prefix}-parent.yml"
    end

    # consider moving these methods into cfn/builder/helpers.rb or that area.
    def api_gateway_template_path
      "#{template_path_prefix}-api-gateway.yml"
    end

    def api_gateway_deployment_template_path
      "#{template_path_prefix}-api-gateway-deployment.yml"
    end

    def parent_stack_name
      File.basename(parent_template_path, ".yml")
    end

    def template_path_prefix
      "#{Jets.tmpdir}/templates/#{Jets.config.project_namespace}"
    end

    def gateway_api_name
      "#{Jets.config.project_namespace}"
    end

    def code_s3_key
      md5_zipfile = File.basename(md5_code_zipfile)
      if ENV['SKIP_CODE_UPLOAD']
        puts "Using jets/code/code.zip code in s3. Assumes this was manually uploaded!".colorize(:red)
      end
      ENV['SKIP_CODE_UPLOAD'] ? "jets/code/code.zip" : "jets/code/#{md5_zipfile}"
    end

    # build was already ran and that a file that contains the md5 path exists
    # at Jets.tmpdir/code/current-md5-filename.txt
    #
    # md5_code_zipfile: /tmp/jets/demo/code/code-2e0e18f6.zip
    def md5_code_zipfile
      IO.read("#{Jets.tmpdir}/code/current-md5-filename.txt")
    end
    # The current-md5-filename.txt gets created as a part of LinuxRuby's build
    # process.
    # And is required to be used much later for cfn/ship and base_child_builder
    # They need set an s3_key which requires the md5_zip_dest.
    # It is a pain to pass this all the way up from the
    # LinuxRuby class.
    # We store the "/tmp/jets/demo/code/code-a8a604aa.zip" into a
    # file that can be read from any places where this is needed.
    # Can also just generate a "fake file" for specs
  end
end
