require 'action_view'
require 'digest'

module Jets::Cfn
  class Upload
    include Jets::AwsServices
    include ActionView::Helpers::NumberHelper # number_to_human_size

    attr_reader :bucket_name

    CONTENT_TYPES_BY_EXTENSION = {
      '.css' => 'text/css',
      '.js' => 'application/javascript',
      '.html' => 'text/html'
    }

    def initialize(bucket_name)
      @bucket_name = bucket_name
    end

    def upload
      upload_cfn_templates
      upload_zip_files
      upload_assets
    end

    def upload_cfn_templates
      puts "Uploading CloudFormation templates to S3."
      expression = "#{Jets::Naming.template_path_prefix}-*"
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        key = "jets/cfn-templates/#{File.basename(path)}"
        obj = s3_resource.bucket(bucket_name).object(key)
        obj.upload_file(path)
      end
    end

    def upload_zip_files
      puts "Uploading code zip files to S3."
      zip_area = "#{Jets.build_root}/stage/zips"
      Dir.glob("#{zip_area}/*").each do |file|
        upload_zip_file(file)
      end
    end

    def upload_zip_file(path)
      file_size = number_to_human_size(File.size(path))

      puts "Uploading #{path} (#{file_size}) to S3"
      start_time = Time.now
      s3_key = "jets/code/#{File.basename(path)}"
      obj = s3_resource.bucket(bucket_name).object(s3_key)
      obj.upload_file(path)
      puts "Uploaded to s3://#{bucket_name}/#{s3_key}".color(:green)
      puts "Time to upload code to s3: #{pretty_time(Time.now-start_time).color(:green)}"
    end

    def upload_assets
      puts "Checking for modified public assets and uploading to S3."
      start_time = Time.now
      upload_public_assets
      puts "Time for public assets to s3: #{pretty_time(Time.now-start_time).color(:green)}"
    end

    def upload_public_assets
      public_folders = %w[public]
      public_folders = add_rack_assets(public_folders)
      public_folders.each do |folder|
        upload_asset_folder(folder)
      end
    end

    def add_rack_assets(public_folders)
      return public_folders unless Jets.rack?
      public_folders + %w[rack/public]
    end

    def upload_asset_folder(folder)
      expression = "#{Jets.root}/#{folder}/**/*"
      group_size = 10
      Dir.glob(expression).each_slice(group_size) do |paths|
        threads = []
        paths.each do |full_path|
          next unless File.file?(full_path)

          threads << Thread.new do
            upload_to_s3(full_path)
          end
        end
        threads.each(&:join)
      end
    end

    def upload_to_s3(full_path)
      return if identical_on_s3?(full_path)

      key = s3_key(full_path)
      obj = s3_resource.bucket(bucket_name).object(key)
      puts "Uploading and setting content type for s3://#{bucket_name}/#{key}" # uncomment to see and debug
      obj.upload_file(full_path, { acl: "public-read", cache_control: cache_control }.merge(content_type_headers(full_path)))
    end

    def content_type_headers(full_path)
      content_type = CONTENT_TYPES_BY_EXTENSION[File.extname(full_path)]
      if content_type
        { content_type: content_type }
      else
        {}
      end
    end

    def s3_key(full_path)
      relative_path = full_path.sub("#{Jets.root}/", '')
      "jets/#{relative_path}"
    end

    def identical_on_s3?(full_path)
      local_md5 = ::Digest::MD5.file(full_path)
      key = s3_key(full_path)
      begin
        resp = s3.head_object(bucket: bucket_name, key: key)
      rescue Aws::S3::Errors::NotFound
        return false
      end

      remote_md5 = resp.etag.delete_prefix('"').delete_suffix('"')
      local_md5 == remote_md5
    end

    # If cache_control is provided, then it will set the entire cache-control header.
    # If only max_age is provided, then we'll generate a cache_control header.
    # Using max_age is the shorter and simply way of setting the cache_control header.
    def cache_control
      cache_control = Jets.config.assets.cache_control
      unless cache_control
        max_age = Jets.config.assets.max_age # defaults to 3600 in jets/application.rb
        cache_control = "public, max-age=#{max_age}"
      end
      cache_control
    end

    # http://stackoverflow.com/questions/4175733/convert-duration-to-hoursminutesseconds-or-similar-in-rails-3-or-ruby
    def pretty_time(total_seconds)
      minutes = (total_seconds / 60) % 60
      seconds = total_seconds % 60
      if total_seconds < 60
        "#{seconds.to_i}s"
      else
        "#{minutes.to_i}m #{seconds.to_i}s"
      end
    end

  end
end