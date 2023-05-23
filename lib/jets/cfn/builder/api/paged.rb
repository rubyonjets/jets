module Jets::Cfn::Builder::Api
  class Paged < Base
    class << self
      def build_pages(options={})
        # IE: Pages::Methods.pages Pages::Resources.pages
        pages_class.pages.each do |page|
          # Key builder here:
          #   Jets::Cfn::Builder::Api::Methods
          #   Jets::Cfn::Builder::Api::Resources
          new(options.merge(page: page)).build
        end
      end

      # Examples:
      #   Pages::Methods.new(options)
      #   Pages::Resources.new(options)
      def pages_class
        class_name = self.to_s.gsub(/.*::Api::/, '') # IE: Methods or Resources
        "Jets::Cfn::Builder::Api::Pages::#{class_name}".constantize
      end
    end

    def initialize(options={})
      super
      @page = options[:page]
      @items = @page.items        # interface method: Cors: paths, Resources: paths, Methods: routes
      @page_number = @page.number # interface method
    end
  end
end
