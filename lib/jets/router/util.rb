module Jets::Router
  module Util
    def underscore(str)
      return unless str
      str.to_s.gsub(/[^a-zA-Z0-9]/,'_')
    end
  end
end