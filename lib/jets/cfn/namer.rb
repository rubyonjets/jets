class Jets::Cfn
  class Namer
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
      "#{Jets::Project.project_name}-#{Jets::Project.env}-#{logical_id.underscore.dasherize}"
    end

    def s3_key
      self.class.s3_key
    end

    def template_path
      self.class.template_path(@controller_class)
    end

  public
    # Class methods

    # @@s3_key = "jets/cfn-templates/dev/#{Time.now.strftime("%Y%m%dT%H%M%S")}/jets-app-code.zip"
    @@s3_key = "jets/cfn-templates/jets.zip" # hardcode to test
    def self.s3_key
      @@s3_key
    end

    def self.template_path(controller_class)
      underscored_controller = controller_class.to_s.underscore.dasherize
      "#{template_prefix}-#{underscored_controller}.yml"
    end

    # consdier moving these methods into cfn/builder/helpers.rb or that area.
    def self.parent_template_path
      "#{template_prefix}-parent.yml"
    end

    def self.parent_stack_name
      File.basename(parent_template_path, ".yml")
    end

    def self.base_template_path
      "#{template_prefix}-base.yml"
    end

    def self.template_prefix
      "/tmp/jets_build/templates/#{Jets::Project.project_name}-#{Jets::Project.env}"
    end
  end
end