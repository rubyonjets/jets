class Jets::Stack
  class Main
    module Dsl
      extend ActiveSupport::Concern
      autoload :Cloudwatch, 'jets/stack/main/extensions/cloudwatch'
      autoload :Sns, 'jets/stack/main/extensions/sns'
      autoload :Sqs, 'jets/stack/main/extensions/sqs'
      autoload :Base, 'jets/stack/main/extensions/base'

      class_methods do
        include Cloudwatch
        include Sns
        include Sqs
        include Base
      end

      def self.included(base)
        base_path = "#{Jets.root}/app/shared/extensions"
        ActiveSupport::Dependencies.autoload_paths += [base_path]

        Dir.glob("#{base_path}/**/*.rb").each do |path|
          puts "path #{path}"
          next unless File.file?(path)

          class_name = path.sub("#{base_path}/", '').sub(/\.rb/,'').classify
          puts "class_name #{class_name}"
          klass = class_name.constantize # autoload

          base.extend(klass)
        end
      end
    end
  end
end
