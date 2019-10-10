module Jets::Cfn
  class Template
    include Jets::AwsServices

    attr_reader :path

    def inilialize(path, options)
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

    def bucket_name
      @options[:s3_bucket]
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
      key = "jets/cfn-templates/#{File.basename(path)}"
      obj = s3_resource.bucket(bucket_name).object(key)
      obj.upload_file(path)
    end
  end
end
