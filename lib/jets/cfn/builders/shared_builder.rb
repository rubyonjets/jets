class Jets::Cfn::Builders
  class SharedBuilder < BaseChildBuilder
    def compose
      add_shared_resources
    end

    def add_shared_resources
      shared_class = @app_class
      puts "shared_class #{shared_class.inspect}"
      # topic = Jets::Resource::Sns::Topic.new(shared_class, definition)
      # add_resource(topic)

      puts "add_shared_resources".colorize(:cyan)
      puts "@app_class: #{@app_class.inspect}"
    end
  end
end
