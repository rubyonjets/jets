module Jets::Router::Resources
  class Filter < Base
    def yes?(action)
      return true unless @options[:only] || @options[:except]

      if @options[:only]
        only = [@options[:only]].flatten.map(&:to_s)
        only.include?(action.to_s)
      else # except
        except = [@options[:except]].flatten.map(&:to_s)
        !except.include?(action.to_s)
      end
    end
  end
end
