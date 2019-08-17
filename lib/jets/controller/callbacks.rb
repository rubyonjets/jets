# Simpified version of callbacks
# Does not support if
class Jets::Controller
  module Callbacks
    extend ActiveSupport::Concern
    included do
      class_attribute :before_actions, default: []
      class_attribute :after_actions, default: []

      class << self
        def before_action(meth, options = {})
          self.before_actions += [[meth, options]]
        end

        def prepend_before_action(meth, options = {})
          self.before_actions = [[meth, options]] + self.before_actions
        end

        def skip_before_action(meth, options = {})
          # adds the methods in the only to the exception list for the callback
          return append_except_to_callbacks(self.before_actions, meth, options[:only]) if options[:only].present?
            
          self.before_actions.reject! { |el| el.first.to_s == meth.to_s }
        end

        alias_method :append_before_action, :before_action

        def after_action(meth, options = {})
          self.after_actions += [[meth, options]]
        end

        def prepend_after_action(meth, options = {})
          self.after_actions = [[meth, options]] + self.after_actions
        end

        def skip_after_action(meth)
          self.after_actions = self.after_actions.reject { |el| el.first.to_s == meth.to_s }
        end

        alias_method :append_after_action, :after_action

        private

        def append_except_to_callbacks(callback_methods, meth, excepted_methods)
          callback_methods.map! do |callback_method|
            if callback_method.first.to_s == meth.to_s
              exceptions = callback_method.second[:except] || []
              exceptions.concat(Array.wrap(excepted_methods))
              callback_method.second[:except] = exceptions
            end

            callback_method
          end
        end
      end
    end # included

    # Instance Methods
    # define run_before_actions and run_after_actions
    # returns true if all actions were run, false if break_if condition yielded `true`
    [:before, :after].each do |type|
      define_method "run_#{type}_actions" do |break_if: nil|
        called_method = @meth.to_sym
        callbacks = self.class.send("#{type}_actions")
        callbacks.each do |array|
          callback, options = array

          except = options[:except]
          next if except && except.include?(called_method)

          only = options[:only]
          if only
            send(callback) if only.include?(called_method)
          else
            send(callback)
          end
          @last_callback_name = callback

          return false if !break_if.nil? && break_if.call
        end
        true
      end
    end
  end # ClassOptions
end
