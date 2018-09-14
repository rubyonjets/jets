module Jets
  class SharedResource
    autoload :Base, 'jets/shared_resource/base'
    autoload :Sns, 'jets/shared_resource/sns'
    autoload :Arn, 'jets/shared_resource/arn'

    class << self
      include Arn

      def build?
        true # always true, checked by cfn/builders/interface.rb
      end

      def sns
        Sns.new(self) # self is the custom resource class. IE: Resource < Jets::Resource
      end

      @@resources = []
      def register_resource(resource)
        @@resources << resource
      end

      def resources
        @@resources
      end

      # Usage:
      #
      #   Jets::SharedResource.resources? # any
      #   Jets::SharedResource.resources?("Resource") # do not include Shared
      def resources?(shared_class=:any)
        # need to eager load the app/shared resources in order to check if shared resources have been registered
        eager_load_shared_resources!
        if shared_class == :any
          !resources.empty?
        else
          !!resources.detect { |r| r.shared_class.to_s == shared_class.to_s }
        end
      end

      def eager_load_shared_resources!
        ActiveSupport::Dependencies.autoload_paths += ["#{Jets.root}app/shared/resources"]
        Dir.glob("#{Jets.root}app/shared/resources/*.rb").select do |path|
          next if !File.file?(path) or path =~ %r{/javascript/} or path =~ %r{/views/}

          class_name = path
                        .sub(/\.rb$/,'') # remove .rb
                        .sub(/^\.\//,'') # remove ./
                        .sub(%r{app/shared/resources/},'') # remove app/shared/resources/
                        .classify
          class_name.constantize # use constantize instead of require so dont have to worry about order.
        end
      end

    end
  end
end