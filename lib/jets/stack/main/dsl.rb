class Jets::Stack
  class Main
    module Dsl
      extend ActiveSupport::Concern

      class_methods do
        include Base
        include Cloudwatch
        include Iam
        include Lambda
        include S3
        include Sns
        include Sqs
      end

      def self.included(base)
        base_path = "#{Jets.root}/app/shared/extensions"
        Dir.glob("#{base_path}/**/*.rb").each do |path|
          next unless File.file?(path)

          class_name = path.sub("#{base_path}/", '').sub(/\.rb/,'').camelize
          klass = class_name.constantize # autoload
          base.extend(klass)
        end
      end
    end
  end
end
