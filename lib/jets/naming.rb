# This class groups the naming in one place.
# Some naming is for CloudFormation
# Some are for the Build process
class Jets::Naming
  # The instance methods are mainly for CloudFormation
  def initialize(controller_class, method_name)
    @controller_class, @method_name = controller_class, method_name
  end

  def handler
    underscored_controller = @controller_class.to_s.sub('Controller', '').underscore
    "handlers/controllers/#{underscored_controller}.#{@method_name}"
  end

  def logical_id
    "#{@controller_class}_#{@method_name}".camelize
  end

  def function_name
    "#{Jets::Config.project_namespace}-#{logical_id.underscore.dasherize}"
  end

  def code_s3_key
    self.class.code_s3_key
  end

  def template_path
    self.class.template_path(@controller_class)
  end

public
  # Mainly build related
  def self.temp_code_zipfile
    "#{Jets.root}code-temp.zip"
  end

  @@md5 = nil # need to store the md5 in memory because the file gets renamed
  def self.md5_code_zipfile
    @@md5 ||= Digest::MD5.file(temp_code_zipfile).to_s[0..7]
    "/tmp/jets_build/code/code-#{@@md5}.zip"
  end

  # Mainly CloudFormation related
  def self.code_s3_key
    md5_zipfile = File.basename(md5_code_zipfile)
    if ENV['SKIP_CODE_UPLOAD']
      puts "Using jets/code/code.zip code in s3. Assumes this was manually uploaded!".colorize(:red)
    end
    ENV['SKIP_CODE_UPLOAD'] ? "jets/code/code.zip" : "jets/code/#{md5_zipfile}"
  end

  def self.template_path(controller_class)
    underscored_controller = controller_class.to_s.underscore.dasherize
    "#{template_path_prefix}-#{underscored_controller}.yml"
  end

  # consider moving these methods into cfn/builder/helpers.rb or that area.
  def self.parent_template_path
    "#{template_path_prefix}-parent.yml"
  end

  # consider moving these methods into cfn/builder/helpers.rb or that area.
  def self.api_gateway_template_path
    "#{template_path_prefix}-api-gateway.yml"
  end

  def self.parent_stack_name
    File.basename(parent_template_path, ".yml")
  end

  def self.template_path_prefix
    "/tmp/jets_build/templates/#{Jets::Config.project_namespace}"
  end

  def self.gateway_api_name
    "#{Jets::Config.project_namespace}"
  end
end
