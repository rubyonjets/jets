class Jets::Cfn::Builder
  class Parent
    include Helpers

    def initialize
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    def compose
      puts "Building parent template"
      add_output("S3Bucket")
      add_output("IamRole")
    end

    def write
      template_path = Jets::Cfn::Namer.parent_template_path
      FileUtils.mkdir_p(File.dirname(template_path))
      IO.write(template_path, text)
    end
  end
end