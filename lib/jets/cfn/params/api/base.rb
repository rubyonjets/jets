# Params are an attempt to centralize the logic for building parameters.
# Params are built at two different times:
# 1. Cfn::Builders::Api::Methods.build_pages
#      => Api::Pages::Methods => api-methods-1.yml nested stack
#    Only uses keys.
# 2. Cfn::Builders::Parent
#      => Resource::Nested::Api::Methods => parent.yml logical id ApiMethods1
#    Uses both keys and values.
module Jets::Cfn::Params::Api
  class Base
    extend Memoist

    def initialize(options={})
      @options = options
      @template = load_template # current paged template_path
      @params = ActiveSupport::HashWithIndifferentAccess.new
    end

    def params
      build # interface method
      @params
    end
    memoize :params

    # Nice to be able to use template or template_path so the common Template.load_file
    # is centralized.
    def load_template
      if @options[:template]
        # At Cfn::Builders::Api::Methods build time, template is in memory
        @options[:template]
      else
        # At Resource::Nested::Api::Methods build time, template is on disk
        Jets::Cfn::Template.load_file(@options[:template_path])
      end
    end

    def build; end # noop by default
  end
end
