class Jets::Stack
  class Main
    module Dsl
      extend ActiveSupport::Concern
      autoload :Base, 'jets/stack/main/extensions/base'
      autoload :Cloudwatch, 'jets/stack/main/extensions/cloudwatch'
      autoload :Iam, 'jets/stack/main/extensions/iam'
      autoload :Lambda, 'jets/stack/main/extensions/lambda'
      autoload :S3, 'jets/stack/main/extensions/s3'
      autoload :Sns, 'jets/stack/main/extensions/sns'
      autoload :Sqs, 'jets/stack/main/extensions/sqs'

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
        ActiveSupport::Dependencies.autoload_paths += [base_path]

        Dir.glob("#{base_path}/**/*.rb").each do |path|
          next unless File.file?(path)

          class_name = path.sub("#{base_path}/", '').sub(/\.rb/,'').classify
          klass = class_name.constantize # autoload
          base.extend(klass)
        end
      end
    end
  end
end
