module Jets
  class Inflections
    class << self
      def load!
        ActiveSupport::Inflector.inflections(:en) do |inflect|
          base_inflections.each do |k,v|
            inflect.irregular k,v
          end
          # Users can add custom inflections
          Jets.config.inflections.irregular.each do |k,v|
            inflect.irregular k,v
          end
        end
      end

      def base_inflections
        {
          sns: 'sns'
        }
      end
    end
  end
end
