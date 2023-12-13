module Jets
  class Code
    include Jets::AwsServices
    include Jets::Util::Logging
    include Jets::Util::Sh

    delegate :s3_bucket, to: "Jets.project"
    delegate :build_root, to: Jets

    def initialize(options = {})
      @options = options
    end

    def zip_and_upload
      command = ARGV.reject { |s| s.match(/^-/) }.join(":") # remove options
      log.info "Packaging code for #{command}: #{Jets.project.namespace}"
      stage
      zip
      upload
    end

    def zip_path
      "#{build_root}/code/code.zip"
    end

    @@s3_key = nil
    def s3_key
      return @@s3_key if @@s3_key

      timestamp = Time.now.utc.strftime("%Y-%m-%dT%H-%M-%SZ")
      git = Jets::Git::Info.new
      branch, sha, dirty = git.params.values_at(:git_branch, :git_sha, :git_dirty)
      sha = sha[0..6] if sha # short sha
      dirty = dirty ? "dirty" : nil
      key = ["jets/code/#{timestamp}", branch, sha, dirty].compact.join("-")
      key = key.gsub(/[^a-zA-Z0-9\-_:\/]/, "-").squeeze("-") # sanitize
      @@s3_key = key + ".zip"
    end

    def s3_location
      "s3://#{s3_bucket}/#{s3_key}"
    end

    def upload
      s3_resource.bucket(s3_bucket).object(s3_key).upload_file(zip_path)
      logger.debug "Uploaded code to s3://#{s3_bucket}/#{s3_key}"
      s3_location # Important to return the s3_location
    end

    def stage
      if @options[:dummy]
        Dummy.new.build
      else
        Stager.new.build
      end
    end

    def zip
      # Check if the folder exists
      unless Dir.exist?("#{build_root}/stage/code")
        logger.info "Error: Source folder not found: #{build_root}/stage/code"
        return
      end

      # Setup
      FileUtils.mkdir_p(File.dirname(zip_path))
      FileUtils.rm_f(zip_path) # remove existing zip file. Else files are added to it

      # Zip
      quiet_sh "cd #{build_root}/stage/code && zip --symlinks -rq #{zip_path} ."

      # Check if the zip operation was successful
      unless $?.success?
        logger.info "Error: Failed to zip the folder: #{build_root}/stage/code"
      end

      zip_path
    end
  end
end
