module Jets::Router::Helpers
  module NamedRoutesHelper
    def self.clear!
      meths = public_instance_methods(false)
      meths.each { |m| remove_method(m) }
    end
  end
end