class Jets::Core::Config::Bootstrap
  module S3Bucket
    attr_accessor :s3_bucket

    def initialize(*)
      super

      @s3_bucket = ActiveSupport::OrderedOptions.new
      @s3_bucket.cors_configuration = {
        CorsRules: [{
          AllowedHeaders: ["*"],
          AllowedMethods: ["GET"],
          AllowedOrigins: ["*"],
          ExposedHeaders: []
        }]
      }
    end
  end
end
