module Jets::Shim::Adapter
  class Event < Base
    def handle
      target_class.handle(event, context, target_method)
    end

    def handle?
      target && target_class && target_method?
    end

    def target_class
      class_name, _ = target.split(".")
      class_name.camelize.constantize
    rescue NameError
    end

    def target_method
      _, method_name = target.split(".")
      method_name ||= "perform"
      method_name.to_sym
    end

    def target_method?
      target_class.public_instance_methods.include?(target_method)
    end
  end
end
