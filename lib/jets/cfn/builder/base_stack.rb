# The base stack has resources that are require by the rest of the stacks.
# It establishes a baseline of resources.
class Jets::Cfn::Builder
  class BaseStack
    include Helpers

    def text
      path = File.expand_path("../templates/base-stack.yml", __FILE__)
      IO.read(path)
    end
  end
end
