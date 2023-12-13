class Jets::Cfn::Stack
  class Template
    extend Memoist
    include Jets::AwsServices

    delegate :s3_bucket, to: "Jets.project"

    attr_reader :path, :stack_name
    def initialize(options = {})
      @options = options
      @path = Jets::Names.parent_template_path
      @stack_name = Jets::Names.parent_stack_name
    end

    def template_option
      if upload_to_s3?
        {template_url: url}
      else
        {template_body: body}
      end
    end

    # uploads to s3 lazily on first call
    def url
      s3_key = "jets/cfn/#{File.basename(path)}"
      object = s3_resource.bucket(s3_bucket).object(s3_key)
      object.upload_file(path)
      "https://s3.amazonaws.com/#{s3_bucket}/#{s3_key}"
    end
    memoize :url

    # Only use filesystem on initial bootstrap
    def body
      IO.read(path)
    end
    memoize :body

    private

    # Should not upload template to s3 and always use local template for bootstrap deploy.
    # This is because for finale deletion stack, uploading the parent.yml to s3
    # prevents a clean deletion of the s3 bucket resource since it's not empty.
    def upload_to_s3?
      !@options[:bootstrap]
    end
  end
end
