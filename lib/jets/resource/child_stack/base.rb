# Inheriting classes should implement:
#
#   definition
#   template_filename
#
module Jets::Resource::ChildStack
  class Base < Jets::Resource::Base
    def initialize(s3_bucket, options={})
      @s3_bucket = s3_bucket
      @options = options
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end

    def template_url
      basename = File.basename(template_filename)
      "https://s3.amazonaws.com/#{@s3_bucket}/jets/cfn-templates/#{basename}"
    end
  end
end
