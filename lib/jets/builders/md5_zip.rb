class Jets::Builders
  class Md5Zip
    include ActionView::Helpers::NumberHelper # number_to_human_size
    include Util

    def initialize(path)
      @path = path
    end

    def create
      headline "Creating zip file for #{@path}"

      # https://serverfault.com/questions/265675/how-can-i-zip-compress-a-symlink
      zip_dest = @path + '.zip'
      zip_file = File.basename(zip_dest)
      command = "cd #{@path} && zip --symlinks -rq #{zip_file} ."
      sh(command)
      FileUtils.mv("#{@path}/#{zip_file}", zip_dest) # move out of the code folder to the stage folder

      # we can get the md5 only after the file has been created
      md5 = Digest::MD5.file(zip_dest).to_s[0..7]
      md5_dest = zip_dest.sub(".zip", "-#{md5}.zip")
      FileUtils.mv(zip_dest, md5_dest)
      # mv /tmp/jets/demo/stage/code.zip /tmp/jets/demo/stage/code-a8a604aa.zip

      file_size = number_to_human_size(File.size(md5_dest))
      puts "Zip file with code and bundled linux ruby created at: #{md5_dest.colorize(:green)} (#{file_size})"

      # Save state
      IO.write("#{Jets.build_root}/code/current-md5-filename.txt", md5_dest)
      # Much later: ship, base_child_builder need set an s3_key which requires
      # the md5_dest.
      # It is a pain to pass this all the way up from the
      # CodeBuilder class.
      # Let's store the "/tmp/jets/demo/code/code-a8a604aa.zip" into a
      # file that can be read from any places where this is needed.
      # Can also just generate a "fake file" for specs
    end
  end
end