module Jets::Cfn
  class Template
    include Jets::AwsServices

    attr_reader :path

    def initialize(path, options={})
      @path = path
      @options = options
    end

    def body
      @body ||= IO.read(path)
    end

    def url
      @url ||= upload_file_to_s3
    end

    def stack_option
      if upload_to_s3?
        from_s3
      else
        from_path
      end
    end

  private
    def upload_to_s3?
      return false if @options[:stack_type] == :minimal # bucket not yet available
      bucket_name.present?
    end

    def bucket_name
      Jets.s3_bucket
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
      obj = s3_resource.bucket(bucket_name).object(s3_key)
      obj.upload_file(path)

      "https://s3.amazonaws.com/#{bucket_name}/#{s3_key}"
    end

    def s3_key
      @s3_key ||= "jets/cfn-templates/#{File.basename(path)}"
    end

    class << self
      # Caches reduce filesystem IO calls
      @@cache = {}
      def load_file(path)
        if @@cache[path]
          @@cache[path]
        else
          @@cache[path] = Jets::Util::Yamler.load_file(path).deep_symbolize_keys
        end
      end

      # Jets::Cfn::Template.lookup_logical_id(template_name, key)
      # Jets::Cfn::Template.lookup_logical_id("api-resources", "UpApiResource")
      def lookup_logical_id(template_name, key)
        expr = "#{Jets::Names.templates_folder}/#{template_name}-*"
        template_paths = Dir.glob(expr).sort.to_a
        found_template = template_paths.detect do |path|
          next unless File.file?(path)

          template = Jets::Cfn::Template.load_file(path)
          template[:Outputs].keys.include?(key.to_sym)
        end

        name = File.basename(found_template).sub(/\.yml$/,'')
        name.underscore.camelize # IE: ApiResources1
      end
    end
  end
end
