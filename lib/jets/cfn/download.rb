module Jets::Cfn
  class Download
    include Jets::AwsServices

    def download_templates(version)
      bucket = s3_resource.bucket(bucket_name)
      unless bucket.exists?
        puts "ERROR: The bucket #{bucket_name} does not exist.".color(:red)
        exit 1
      end

      # Cleanup templates folder
      FileUtils.rm_rf(Jets::Names.templates_folder)
      FileUtils.mkdir_p(Jets::Names.templates_folder)

      key_path = "jets/cfn-templates/versions/#{version}"
      objects = bucket.objects(prefix: key_path)
      if objects.count > 0
        objects.each do |object|
          file_name = "#{Jets::Names.templates_folder}/#{object.key.split('/').last}"
          object.get(response_target: file_name)
          puts "Downloaded #{file_name} from s3://#{bucket_name}/#{object.key}" if ENV['JETS_DEBUG']
        end
      else
        puts "ERROR: Cannot rollback to this version because the CloudFormation templates are not available.".color(:red)
        puts <<~EOL
          This can happen the app was deployed before Jets Pro features were enabled,
          or if the stack was delete and redeployed. Deleted stacks history are not
          rollbackable because their original s3 bucket is deleted.
        EOL
        exit 1
      end
    end

    def bucket_name
      Jets.s3_bucket
    end
  end
end
