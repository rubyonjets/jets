module Jets::Rack
  class AdapterController < Jets::Controller::Base
    extend Memoist

    def process
      triplet = app.call(rack_env)
      convert_to_api_gateway(triplet) # resp
    end

    def app
      Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, ['get rack\'d']] }
      # Rails.application
    end

    def rack_env
      builder = Env.new(event)
      builder.build
    end
    memoize :rack_env

    def convert_to_api_gateway(triplet)
      builder = Jets::Rack::ApiGateway.new(triplet)
      builder.build # resp
    end
  end
end
