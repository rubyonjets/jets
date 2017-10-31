class Jets::Cfn::Builder
  class LambdaFunctionMapper
    attr_reader :controller # Example: PostsController
    def initialize(controller, method_name)
      @controller, @method_name = controller.to_s, method_name
    end

    def lambda_function_logical_id
      "#{controller_action}LambdaFunction"
    end

    # Example: PostsControllerIndex
    def controller_action
      "#{@controller}_#{@method_name}".camelize
    end

    ###############################
    def function_name
      method = "#{@controller}_#{@method_name}".underscore.dasherize
      "#{Jets::Config.project_namespace}-#{method}"
    end

    def handler
      underscored = @controller.to_s
                      .sub('Controller', '')
                      .sub('Job', '')
                      .underscore
      "handlers/controllers/#{underscored}.#{@method_name}"
    end

    def code_s3_key
      self.class.code_s3_key
    end

    def self.code_s3_key
      md5_zipfile = File.basename(md5_code_zipfile)
      if ENV['SKIP_CODE_UPLOAD']
        puts "Using jets/code/code.zip code in s3. Assumes this was manually uploaded!".colorize(:red)
      end
      ENV['SKIP_CODE_UPLOAD'] ? "jets/code/code.zip" : "jets/code/#{md5_zipfile}"
    end

    @@md5 = nil # need to store the md5 in memory because the file gets renamed
    def self.md5_code_zipfile
      @@md5 ||= ENV['TEST'] ? 'TEST' : Digest::MD5.file(Jets::Naming.temp_code_zipfile).to_s[0..7]
      "/tmp/jets_build/code/code-#{@@md5}.zip"
    end

  end
end