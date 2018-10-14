require 'action_view'

class Jets::Cfn
  class Upload
    include Jets::AwsServices
    include ActionView::Helpers::NumberHelper # number_to_human_size

    attr_reader :bucket_name
    def initialize(bucket_name)
      @bucket_name = bucket_name
    end

    def upload
      upload_cfn_templates
      upload_zip_files
      upload_assets
    end

    def upload_cfn_templates
      puts "Uploading child CloudFormation templates to S3"
      expression = "#{Jets::Naming.template_path_prefix}-*"
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        key = "jets/cfn-templates/#{File.basename(path)}"
        obj = s3_resource.bucket(bucket_name).object(key)
        obj.upload_file(path)
      end
    end

    # build was already ran and that a file that contains the md5 path exists
    # at Jets.build_root/code/current-md5-filename.txt
    #
    # md5_code_zipfile: /tmp/jets/demo/code/code-2e0e18f6.zip
    # The current-md5-filename.txt gets created as a part of CodeBuilder's build
    # process.
    #
    # And is required to be used much later for cfn/ship and base_child_builder
    # They need set an s3_key which requires the md5_zip_dest.
    # It is a pain to pass this all the way up from the
    # CodeBuilder class.
    #
    # We store the "/tmp/jets/demo/code/code-a8a604aa.zip" into a
    # file that can be read from any places where this is needed.
    # Can also just generate a "fake file" for specs
    def upload_zip_files
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
      puts "Uploaded to s3://#{bucket_name}/#{s3_key}"
      puts "Time to upload code to s3: #{pretty_time(Time.now-start_time).colorize(:green)}"
    end

    def upload_assets
      puts "Uploading public assets"
      start_time = Time.now
      asset_folders = Jets.config.assets.folders
      asset_folders.each do |folder|
        upload_asset_folder(folder)
      end
      puts "Time to upload public assets to s3: #{pretty_time(Time.now-start_time).colorize(:green)}"
    end

    def upload_asset_folder(folder)
      expression = "#{Jets.root}public/#{folder}/**/*"
      group_size = 10
      Dir.glob(expression).each_slice(group_size) do |paths|
        threads = []
        paths.each do |path|
          next unless File.file?(path)

          regexp = Regexp.new(".*/#{folder}/")
          relative_path = path.sub(regexp,'')
          file = "#{folder}/#{relative_path}"

          threads << Thread.new do
            upload_asset_file(file)
          end
        end
        threads.each(&:join)
      end
    end

    def upload_asset_file(file)
      path = "#{Jets.root}public/#{file}"
      key = "jets/public/#{file}"
      puts "Uploading s3://#{bucket_name}/#{key}" # uncomment to see and debug
      obj = s3_resource.bucket(bucket_name).object(key)
      obj.upload_file(path, acl: "public-read", cache_control: cache_control)
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