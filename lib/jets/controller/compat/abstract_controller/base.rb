require "abstract_controller/error"
require "active_support/configurable"
require "active_support/descendants_tracker"
require "active_support/core_ext/module/anonymous"
require "active_support/core_ext/module/attr_internal"

module Jets::Controller::Compat::AbstractController
  module Base
    extend ActiveSupport::Concern
    include ActiveSupport::Configurable

    delegate :action_methods,
             :controller_name,
             :controller_path,
             to: :class
    class_methods do
      # A list of method names that should be considered actions. This
      # includes all public instance methods on a controller, less
      # any internal methods (see internal_methods), adding back in
      # any methods that are internal, but still exist on the class
      # itself.
      #
      # ==== Returns
      # * <tt>Set</tt> - A set of all methods that should be considered actions.
      def action_methods
        @action_methods ||= begin
          # All public instance methods of this class, including ancestors
          methods = (public_instance_methods(true) -
            # Except for public instance methods of Base and its ancestors
            internal_methods +
            # Be sure to include shadowed public instance methods of this class
            public_instance_methods(false))

          methods.map!(&:to_s)

          methods.to_set
        end
      end

        # A list of all internal methods for a controller. This finds the first
      # abstract superclass of a controller, and gets a list of all public
      # instance methods on that abstract class. Public instance methods of
      # a controller would normally be considered action methods, so methods
      # declared on abstract classes are being removed.
      # (ActionController::Metal and ActionController::Base are defined as abstract)
      def internal_methods
        controller = self

        controller = controller.superclass until controller.abstract?
        controller.public_instance_methods(true)
      end

      def controller_name
        @controller_name ||= name.demodulize.delete_suffix("Controller").underscore
      end

      def controller_path
        @controller_path ||= name.delete_suffix("Controller").underscore
      end

      # Returns true if the given controller is capable of rendering
      # a path. A subclass of +AbstractController::Base+
      # may return false. An Email controller for example does not
      # support paths, only full URLs.
      def supports_path?
        true
      end
    end

    ##
    # Returns the body of the HTTP response sent by the controller.
    attr_internal :response_body

    ##
    # Returns the name of the action this controller is processing.
    def action_name
      @meth
    end

    def available_action?(action_name)
      self.class.action_methods.include?(action_name.to_s)
    end

    # Tests if a response body is set. Used to determine if the
    # +process_action+ callback needs to be terminated in
    # AbstractController::Callbacks.
    def performed?
      if response_body.respond_to?(:each)
        !response_body.compact.empty? # [""] is considered true
      else # nil
        !response_body.nil?
      end
    end

    def inspect # :nodoc:
      "#<#{self.class.name}:#{'%#016x' % (object_id << 1)}>"
    end

  private
    # Returns true if the name can be considered an action because
    # it has a method defined in the controller.
    #
    # ==== Parameters
    # * <tt>name</tt> - The name of an action to be tested
    def action_method?(name)
      self.class.action_methods.include?(name)
    end

    # Call the action. Override this in a subclass to modify the
    # behavior around processing an action. This, and not #process,
    # is the intended way to override action dispatching.
    #
    # Notice that the first argument is the method to be dispatched
    # which is *not* necessarily the same as the action name.
    def process_action
      send_action(action_name) # to BasicImplicitRender#send_action => super (posts#index) or default_render
    end

    # Actually call the method associated with the action. Override
    # this method if you wish to change how action methods are called,
    # not to add additional behavior around it. For example, you would
    # override #send_action if you want to inject arguments into the
    # method.
    alias send_action send
  end
end
