# Interface:
#   subclasses must implement render
module Jets::Controller::Renderers
  class BaseRenderer
    delegate :request, :event, :headers, to: :controller
    attr_reader :controller
    def initialize(controller, options={})
      @controller = controller
      @options = options
    end
  end
end
