class Jets::Build::Deducer
  class ControllerDeducer < BaseDeducer
    # interface method
    def process_type
      "controller"
    end

    # Returns: [:create, :update]
    def functions
      require "#{Jets.root}app/controllers/application_controller"

      # Example: require "./app/controllers/posts_controller.rb"
      require_path = @path.starts_with?('/') ? @path : "#{Jets.root}#{@path}"
      require require_path

      class_name
      klass = class_name.constantize
      klass.lambda_functions
    end
  end
end
