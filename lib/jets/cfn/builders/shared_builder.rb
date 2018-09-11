class Jets::Cfn::Builders
  class SharedBuilder < BaseChildBuilder
    def compose
      add_shared_resources
    end

    def add_shared_resources
      shared_class = @app_class
      puts "shared_class #{shared_class.inspect}"

      Jets::SharedResource.resources.each do |resource|
        puts "resource #{resource.inspect}"
        add_resource(resource)
      end

      # Jets::SharedResource.resources.each do |shared_class, definition|
      #   puts "shared_class #{shared_class} definition #{definition.inspect}"
      # end

      # topic = Jets::Resource::Sns::Topic.new(shared_class, definition)
      # add_resource(topic)

      puts "add_shared_resources".colorize(:cyan)
      puts "@app_class: #{@app_class.inspect}"
    end

    # template_path is an interface method for Interface module
    def template_path
      Jets::Naming.shared_template_path(@app_class)
    end
  end
end
