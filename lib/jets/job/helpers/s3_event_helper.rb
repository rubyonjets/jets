module Jets::Job::Helpers
  module S3EventHelper
    def s3_event
      message = event["Records"][0]["Sns"]["Message"]
      h = JSON.load(message)
      ActiveSupport::HashWithIndifferentAccess.new(h)
    end

    def s3_object
      s3_event["Records"][0]["s3"]["object"]
    end
  end
end
