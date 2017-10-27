# The base stack has resources that are require by the rest of the stacks.
# It establishes a baseline of resources.
class Jets::Cfn::Builder
  class BaseStack
    include Helpers

    def text
    end

    # TODO: very duplicated logic, refactor so we only have a template_name method
    # def template_name
    #   Jets::Cfn::Namer.base_template_path
    #   Jets::Cfn::Namer.parent_template_path
    #   Jets::Cfn::Namer.template_path(@controller_class)
    # end
    def write
      template_path = Jets::Cfn::Namer.base_template_path
      puts "writing base stack template #{template_path}"
      FileUtils.mkdir_p(File.dirname(template_path))
      IO.write(template_path, text)
    end
  end
end
