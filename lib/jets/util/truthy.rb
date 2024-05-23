module Jets::Util
  module Truthy
    # Allows use non-truthy values like
    #   n no false off null nil 0
    def truthy?(value)
      %w[y yes true on 1].include?(value.to_s.downcase)
    end
  end
end
