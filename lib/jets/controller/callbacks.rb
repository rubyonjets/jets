# Simpified version of callbacks
# Does not support if
class Jets::Controller
  module Callbacks
    extend ActiveSupport::Concern
    included do
      class_attribute :before_actions
      self.before_actions = []
      class_attribute :after_actions
      self.after_actions = []

      def self.before_action(meth, options={})
        self.before_actions += [[meth, options]]
      end

      def self.after_action(meth, options={})
        self.after_actions += [[meth, options]]
      end
    end # included

    # Instance Methods
    # define run_before_actions and run_after_actions
    [:before, :after].each do |type|
      define_method "run_#{type}_actions" do
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
        end
      end
    end
  end # ClassOptions
end
