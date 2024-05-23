module Jets::Stack::Dsl
  module Main
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
  end
end
