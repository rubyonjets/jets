module Jets::Cfn::Resource::Nested::Api
  class Page < Base
    def initialize(options={})
      super
      @page_number = options[:page_number]
    end
  end
end
