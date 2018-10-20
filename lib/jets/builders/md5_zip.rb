require 'action_view'

# Examples:
#
#   zip = Jets::Builders::Md5Zip.new("/tmp/jets/demo/stage/code")
#   zip.create
#
#   zip = Jets::Builders::Md5Zip.new("/tmp/jets/demo/stage/bundled")
#   zip.create
#
class Jets::Builders
  class Md5Zip
    include ActionView::Helpers::NumberHelper # number_to_human_size
    include Util

    def initialize(short_path)
      @path = "#{Jets.build_root}/#{short_path}"
      @checksum = Md5.checksums[short_path]
    end

    def create
      headline "Creating zip file for #{@path}"

      # https://serverfault.com/questions/265675/how-can-i-zip-compress-a-symlink
      stage_area, filename = File.dirname(@path), File.basename(@path)
      zip_area = stage_area + '/zips' # /tmp/jets/demo/stage/zips
      zip_file = filename + '.zip' # code.zip

      command = "cd #{@path} && zip --symlinks -rq #{zip_file} ."
      sh(command)
      # move out of the lower folder to the stage folder
      # mv /tmp/jets/demo/stage/code/code.zip /tmp/jets/demo/stage/code.zip
      zip_dest = "#{zip_area}/#{zip_file}"
      FileUtils.mkdir_p(File.dirname(zip_dest))
      FileUtils.mv("#{@path}/#{zip_file}", zip_dest)

      # we can get the md5 only after the file has been created
      # md5 = Digest::MD5.file(zip_dest).to_s[0..7]
      # md5_dest = zip_dest.sub(".zip", "-#{md5}.zip")
      md5_dest = zip_dest.sub(".zip", "-#{@checksum}.zip")
      # # mv /tmp/jets/demo/stage/zips/code.zip /tmp/jets/demo/stage/zips/code-a8a604aa.zip
      FileUtils.mv(zip_dest, md5_dest)

      file_size = number_to_human_size(File.size(md5_dest))
      puts "Zip file created at: #{md5_dest.colorize(:green)} (#{file_size})"

      # Save references state
      # Much later: ship, base_child_builder need set an s3_key which requires the md5_dest.
      # It is a pain to pass this all the way up from the Md5Zip class.
      # Store the "/tmp/jets/demo/code/code-a8a604aa.zip" into a file that can be
      # read from any places that's needed.
      # For specs, can generate a "fake file".
      ref = File.dirname(@path) + "/ref/" + File.basename(@path) + ".txt"
      # The reference to the actual md5_dest
      FileUtils.mkdir_p(File.dirname(ref))
      IO.write(ref, md5_dest)
    end
  end
end