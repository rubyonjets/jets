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
    end
  end
end
