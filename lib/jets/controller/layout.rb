class Jets::Controller
  module Layout
    extend ActiveSupport::Concern
    included do
      class_attribute :layout_name

      def self.layout(name=nil)
        if !name.nil?
          name = name.to_s if name.is_a?(Symbol)
          self.layout_name = name
        else
          self.layout_name
        end
      end
    end # included
  end # Layout
end
