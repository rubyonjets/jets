class Jets::Cfn
  class Namer
    def initialize(controller_class, method_name)
      @controller_class, @method_name = controller_class, method_name
    end

    def handler
      controller_name = @controller_class.to_s.sub('Controller', '').underscore
      "handlers/controllers/#{controller_name}.#{@method_name}"
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

    # @@s3_key = "jets/cfn-templates/dev/#{Time.now.strftime("%Y%m%dT%H%M%S")}/jets-app-code.zip"
    @@s3_key = "jets/cfn-templates/code.zip" # hardcode to test
    def self.s3_key
      @@s3_key
    end
  end
end