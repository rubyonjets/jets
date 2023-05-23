# Rails implements with abstract_controller/turbines/routes_helpers.rb
#
# It's implement it this way by Rails so that the controller class _routes
# definition points at the namespace engine routes correctly.
#
# This _routes controller class method used in ActionView::Rendering to create a
# view_context_class that includes the routes url_helpers and mounted_helpers.
#
require "active_support/core_ext/module/introspection"

module JetsTurbines
  module RoutesHelpers
    def self.with(routes, include_path_helpers = true)
      Module.new do
        define_method(:inherited) do |klass|
          super(klass)

          namespace = klass.module_parents.detect { |m| m.respond_to?(:turbine_routes_url_helpers) }
          actual_routes = namespace ? namespace.turbine_routes_url_helpers._routes : routes

          if namespace
            klass.include(namespace.turbine_routes_url_helpers(include_path_helpers))
          else
            klass.include(routes.url_helpers(include_path_helpers))
          end

          # In the case that we have ex.
          #   class A::Foo < ApplicationController
          #   class Bar < A::Foo
          # We will need to redefine _routes because it will not be correct
          # via inheritance.
          unless klass._routes.equal?(actual_routes)
            klass.redefine_singleton_method(:_routes) { actual_routes }
            klass.include(Module.new do
              define_method(:_routes) { @_routes || actual_routes }
            end)
          end
        end
      end
    end
  end
end
