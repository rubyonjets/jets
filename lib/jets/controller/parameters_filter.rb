require "active_support/parameter_filter"

class Jets::Controller
  class ParametersFilter
    attr_reader :filters, :params_filter

    def initialize(filters)
      @filters = filters
      @params_filter = ActiveSupport::ParameterFilter.new(filters)
    end

    def filter(params)
      params && params_filter.filter(params)
    end

    def filter_json(json_text)
      return json_text if filters.blank? || json_text.blank?

      begin
        hash_params = JSON.parse(json_text)
        filtered_params = filter(hash_params)
        JSON.dump(filtered_params)
      rescue JSON::ParserError
        String.new
      end
    end

  end
end
