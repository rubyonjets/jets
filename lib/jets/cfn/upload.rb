require 'active_support/number_helper'
require 'digest'
require 'rack/mime'

module Jets::Cfn
  class Upload
    include Jets::AwsServices
    include ActiveSupport::NumberHelper # number_to_human_size

    def upload
      upload_cfn_templates
      upload_zip_files
      upload_assets
    end

    def bucket_name
      Jets.s3_bucket
    end

    def upload_cfn_templates(version=nil)
      puts "Uploading CloudFormation templates to S3." unless version # hide message when version is passed in
      expression = "#{Jets::Names.templates_folder}/*"
      if version # outside of each loop to avoid repeating
        version = "versions/#{version}"
      else
        checksum = Jets::Builders::Md5.checksums["stage/code"]
        version = "shas/#{checksum}"
      end
      checksum = Jets::Builders::Md5.checksums["stage/code"]
      Dir.glob(expression).each do |path|
        next unless File.file?(path)
        key = ["jets/cfn-templates", version, File.basename(path)].compact.join('/')
        obj = s3_resource.bucket(bucket_name).object(key)
        puts "Uploading #{path} to s3://#{bucket_name}/#{key}".color(:green) if ENV['JETS_DEBUG']
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
      public_folders.each do |folder|
        upload_asset_folder(folder)
      end
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
      if identical_on_s3?(full_path) && !ENV['JETS_ASSET_UPLOAD_FORCE']
        puts "Asset is identical on s3: #{full_path}" if ENV['JETS_DEBUG_ASSETS']
        return
      end

      key = s3_key(full_path)
      obj = s3_resource.bucket(bucket_name).object(key)
      content_type = content_type_headers(full_path)
      if ENV['JETS_DEBUG_ASSETS']
        puts "Uploading and setting content type for s3://#{bucket_name}/#{key} content_type #{content_type[:content_type].inspect}"
      end
      obj.upload_file(full_path, { acl: "public-read", cache_control: cache_control }.merge(content_type))
    end

    CONTENT_TYPES_BY_EXTENSION = {
      '.css'  => 'text/css',
      '.html' => 'text/html',
      '.js'   => 'application/javascript',
    }
    def content_type_headers(full_path)
      ext = File.extname(full_path)
      content_type = CONTENT_TYPES_BY_EXTENSION[ext] || Rack::Mime.mime_type(ext)
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
