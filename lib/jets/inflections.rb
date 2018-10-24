module Jets
  class Inflections
    class << self
      def load!
        ActiveSupport::Inflector.inflections(:en) do |inflect|
          base_inflections.each do |k,v|
            inflect.irregular k,v
          end
          # User defined custom inflections
          inflections_yaml = "#{Jets.root}config/inflections.yml"
          if File.exist?(inflections_yaml)
            inflections = YAML.load_file(inflections_yaml)
            inflections.each do |k,v|
              inflect.irregular k,v
            end
          end
        end
      end

      # base custom inflections
      def base_inflections
        {
          sns: 'sns'
        }
      end
    end
  end
end
