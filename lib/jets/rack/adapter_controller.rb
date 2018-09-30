module Jets::Rack
  class AdapterController < Jets::Controller::Base
    layout false
    internal true
    extend Memoist

    def app
      # Not thread-safe so will move to outside of the handler
      Dir.chdir("#{Jets.root}rack") do
        instance_eval(config_ru_code) # @rack_app will be available after this
      end
      @rack_app # The rack app
    end

    # Takes config.ru code and changes it so we can grab the rack app from it
    # The rack_app is assigned as @rack_app.
    def config_ru_code
      rack_config = "config.ru" # using Dir.chdir to change directory
      unless File.exist?(rack_config)
        puts "ERROR: #{rack_config} does not exist.  In order to use Mega Mode there needs to be a rack/config.ru file.".colorize(:red)
        exit 1
      end
      lines = IO.readlines(rack_config)
      code = lines.map do |l|
        if l =~ /^run /
          l.sub(/^run /,'@rack_app = ')
        else
          l
        end
      end.join("\n") + "\n"
      puts code
      code
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
