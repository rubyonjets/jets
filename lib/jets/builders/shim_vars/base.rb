module Jets::Builders::ShimVars
  class Base
    include Jets::AwsServices
    extend Memoist

    def s3_bucket
      resp = cfn.describe_stacks(stack_name: Jets::Naming.parent_stack_name)
      stack = resp.stacks.first
      output = stack["outputs"].find { |o| o["output_key"] == "S3Bucket" }
      output["output_value"] # s3_bucket
    end
    memoize :s3_bucket

    def rack_zip
      checksum = Jets::Builders::Md5.checksums["stage/rack"]
      "jets/code/rack-#{checksum}.zip"
      # File.basename(IO.read("#{stage_area}/ref/rack.txt")).strip
    end

    def bundled_zip
      checksum = Jets::Builders::Md5.checksums["stage/bundled"]
      "jets/code/bundled-#{checksum}.zip"
      # File.basename(IO.read("#{stage_area}/ref/bundled.txt")).strip
    end

    def stage_area
      "#{Jets.build_root}/stage"
    end
  end
end
