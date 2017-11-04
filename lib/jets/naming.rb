# This class groups the naming in one place.
# Some naming is for CloudFormation
# Some are for the Build process
class Jets::Naming
  # Mainly used by build.rb
  class << self
    def temp_code_zipfile
      "#{Jets.root}code-temp.zip"
    end

    def template_path(controller_class)
      underscored_controller = controller_class.to_s.underscore.dasherize
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
      "/tmp/jets_build/templates/#{Jets.config.project_namespace}"
    end

    def gateway_api_name
      "#{Jets.config.project_namespace}"
    end

    @@md5 = nil # need to store the md5 in memory because the file gets renamed
    def md5_code_zipfile
      @@md5 ||= ENV['TEST'] ? 'TEST' : Digest::MD5.file(Jets::Naming.temp_code_zipfile).to_s[0..7]
      "/tmp/jets_build/code/code-#{@@md5}.zip"
    end

    def code_s3_key
      md5_zipfile = File.basename(Jets::Naming.md5_code_zipfile)
      if ENV['SKIP_CODE_UPLOAD']
        puts "Using jets/code/code.zip code in s3. Assumes this was manually uploaded!".colorize(:red)
      end
      ENV['SKIP_CODE_UPLOAD'] ? "jets/code/code.zip" : "jets/code/#{md5_zipfile}"
    end
  end
end
