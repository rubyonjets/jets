module Jets::Builders::ShimVars
  class Base
    include Jets::AwsServices
    extend Memoist

    def s3_bucket
      Jets.aws.s3_bucket
    end

    def rack_zip
      checksum = Jets::Builders::Md5.checksums["stage/rack"]
      "rack-#{checksum}.zip"
    end

    def bundled_zip
      checksum = Jets::Builders::Md5.checksums["stage/bundled"]
      "bundled-#{checksum}.zip"
    end

    def stage_area
      "#{Jets.build_root}/stage"
    end
  end
end
