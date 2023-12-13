module Jets::Util
  module Camelize
    # Not named camelize! because it conflicts with zeitwerk's camelize!
    def camelize(object)
      result = case object
      when Array
        object.map { |o| camelize(o) }
      when Hash
        Jets::Camelizer.transform(object).deep_symbolize_keys
      else
        object
      end

      case object
      when Symbol
        object
      when NilClass
        nil
      else
        object.replace(result)
      end
    end
  end
end
