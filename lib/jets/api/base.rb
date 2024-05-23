module Jets::Api
  class Base
    include Jets::Api
    class << self
      include Jets::Api
    end
  end
end
