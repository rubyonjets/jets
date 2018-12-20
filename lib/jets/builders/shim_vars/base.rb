module Jets::Builders::ShimVars
  class Base
    include Jets::AwsServices
    extend Memoist

    def s3_bucket
      Jets.aws.s3_bucket
    end

    def rack_zip
      checksum_zip(:rack)
    end

    def bundled_zip
      checksum_zip(:bundled)
    end

  private
    def checksum_zip(name)
      checksum = Jets::Builders::Md5.checksums["stage/#{name}"]
      return unless checksum
      "#{name}-#{checksum}.zip"
    end
  end
end
