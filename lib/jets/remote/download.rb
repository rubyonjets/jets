module Jets::Remote
  class Download < Base
    delegate :s3_bucket, to: "Jets.project"

    def initialize(command)
      @command = command
    end

    def download_built
      # build deploy ci:build ci:deploy waf:build waf:deploy
      subcommand = @command.split(":").last
      case subcommand
      when "build", "deploy", "dockerfile"
        download_templates
        download_dockerfile
      end
    end

    def download_dockerfile
      s3_key = "jets/sigs/#{sig}/docker/Dockerfile"
      object = s3_resource.bucket(s3_bucket).object(s3_key)
      # Can not exists for: jets build --templates
      if object.exists?
        dest = "#{Jets.build_root}/docker/Dockerfile"
        FileUtils.mkdir_p(File.dirname(dest))
        object.download_file(dest)
        if @command.split(":").last == "dockerfile"
          log.info "Dockerfile at: #{dest}"
        else
          log.debug "Download: #{dest}"
        end
      end
    end

    def download_templates
      clean_all_templates
      download_all_templates
    end

    def clean_all_templates
      FileUtils.rm_rf("#{Jets.build_root}/templates")
    end

    def download_all_templates
      s3.list_objects(bucket: s3_bucket, prefix: "jets/sigs/#{sig}/templates/").each do |resp|
        resp.contents.each do |object|
          download_template(object.key)
        end
      end
    end

    def download_template(s3_key)
      object = s3_resource.bucket(s3_bucket).object(s3_key)
      path = object.key.sub("jets/sigs/#{sig}/templates/", "")
      dest = "#{Jets.build_root}/templates/#{path}"
      log.debug "Download: #{dest}"
      FileUtils.mkdir_p(File.dirname(dest))
      object.download_file(dest)
    end

    def sig
      Jets::Remote::Runner.sig
    end
  end
end
