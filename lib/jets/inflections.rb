module Jets
  class Inflections
    class << self
      def load!
        ActiveSupport::Inflector.inflections(:en) do |inflect|
          load(inflect, base)
          load(inflect, custom)
        end
      end

      def load(inflect, inflections)
        inflections.each do |k,v|
          inflect.irregular k,v
        end
      end

      # base custom inflections
      def base
        {
          sns: 'sns',
          sqs: 'sqs'
        }
      end

      # User defined custom inflections
      def custom
        path = "#{Jets.root}config/inflections.yml"
        File.exist?(path) ? YAML.load_file(path) : {}
      end
    end
  end
end
