# Interface:
#   subclasses must implement render
module Jets::Controller::Renderers
  class BaseRenderer
    def initialize(options)
      @options = options
    end
  end
end
