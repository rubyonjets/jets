class Jets::Build::Deducer
  class ControllerDeducer < BaseDeducer
    # interface method
    def process_type
      "controller"
    end

    # interface method
    # Returns: [:create, :update]
    def functions
      # Example: require "./app/controllers/posts_controller.rb"
      require_path = @path.starts_with?('/') ? @path : "#{Jets.root}#{@path}"
      require require_path

      class_name
      klass = class_name.constantize
      klass.lambda_functions
    end
  end
end
