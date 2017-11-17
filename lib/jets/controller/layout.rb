class Jets::Controller
  module Layout
    extend ActiveSupport::Concern
    included do
      class_attribute :layout_name

      def self.layout(name=nil)
        if name
          self.layout_name = name.to_s
        else
          self.layout_name
        end
      end
    end # included
  end # ClassOptions
end
