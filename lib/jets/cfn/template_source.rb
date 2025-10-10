module Jets::Cfn
  class TemplateSource
    include Jets::AwsServices

    attr_reader :path

    def initialize(path, options)
      @path = path
      @options = options
    end

    def body
      @body ||= IO.read(path)
    end

    def url
      @url ||= upload_file_to_s3
    end

    def to_h
      if upload_to_s3?
        from_s3
      else
        from_path
      end
    end

    private

    def upload_to_s3?
      bucket_name.present?
    end

    def from_s3
      {
        template_url: url
      }
    end

    def from_path
      {
        template_body: body
      }
    end

    def upload_file_to_s3
      transfer_manager.upload_file(path, bucket: bucket_name, key: s3_key)

      "https://s3.amazonaws.com/#{bucket_name}/#{s3_key}"
    end

    def bucket_name
      @options[:s3_bucket]
    end

    def s3_key
      @s3_key ||= "jets/cfn-templates/#{File.basename(path)}"
    end

    def transfer_manager
      @transfer_manager ||= Aws::S3::TransferManager.new
    end
  end
end
