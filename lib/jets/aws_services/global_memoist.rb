# We cache the clients globally to avoid re-instantiating them again after the initial Lambda cold start.
#
# Based on: https://hashrocket.com/blog/posts/implementing-a-macro-in-ruby-for-memoization
# Except we use a global variable for the cache. So we'll use the same client across
# all instances as well as across Lambda executions after the cold-start. Example:
#
#   class Foo
#     def s3
#       Aws::S3::Client.new
#     end
#     global_memoize :s3
#   end
#
#   foo1 = Foo.new
#   foo2 = Foo.new
#   foo1.s3
#   foo2.s3 # same client as foo1
#
# A prewarmed request after a cold-start will still use the same s3 client instance since it uses the
# global variable $__memo_methods as the cache.
#
module Jets::AwsServices
  module GlobalMemoist
    def self.included(klass)
      klass.extend(Macros)
    end

    module Macros
      def global_memoize(*methods)
        const_defined?(:"GlobalMemoist#{self.object_id}") ?
          const_get(:"GlobalMemoist#{self.object_id}") : const_set(:"GlobalMemoist#{self.object_id}", Module.new)
        mod = const_get(:"GlobalMemoist#{self.object_id}")

        mod.class_eval do
          methods.each do |method|
            define_method(method) do |skip_cache = false|
              $__memo_methods ||= {}
              if $__memo_methods.include?(method) && !skip_cache
                $__memo_methods[method]
              else
                $__memo_methods[method] = super()
              end
            end
          end
        end
        prepend mod
      end

      def global_memoize_class_method(*methods)
        singleton_class.class_eval do
          include GlobalMemoist
          global_memoize(*methods)
        end
      end
    end
  end
end