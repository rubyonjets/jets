# Inheriting classes should implement:
#
#   definition
#   template_filename
#
module Jets::Cfn::Resource::Nested
  class Base < Jets::Cfn::Base
    def initialize(options={})
      @options = options # not used yet
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end

    def template_url
      checksum = Jets::Builders::Md5.checksums["stage/code"]
      "https://s3.amazonaws.com/#{Jets.s3_bucket}/jets/cfn-templates/shas/#{checksum}/#{template_filename}"
    end

    # Examples:
    #   api-gateway.yml
    #   api-resources-1.yml
    #   api-methods-1.yml
    #   app-posts_controller.yml
    #   shared-custom.yml
    def template_filename
      filename = if @path # AppClass, Authorizer, Shared
        @path.sub("#{Jets::Names.templates_folder}/", '').gsub('/','-').sub('.yml', '')
      else
          self.class.name.to_s.sub(/.*Nested::/,'').underscore.gsub('/','-').dasherize
        end
      [filename, @page_number].compact.join('-') + '.yml'
    end
  end
end
