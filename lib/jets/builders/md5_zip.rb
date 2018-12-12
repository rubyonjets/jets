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

    def initialize(folder)
      @path = "#{Jets.build_root}/#{folder}"
      @checksum = Md5.checksums[folder]
    end

    def create
      headline "Creating zip file for #{@path}"
      # => Creating zip file for /tmp/jets/demo/stage/bundled

      # https://serverfault.com/questions/265675/how-can-i-zip-compress-a-symlink
      command = "cd #{@path} && zip --symlinks -rq #{zip_file} ."
      sh(command)
      # move out of the lower folder to the stage folder
      # mv /tmp/jets/demo/stage/code/code.zip /tmp/jets/demo/stage/code.zip
      FileUtils.mkdir_p(File.dirname(zip_dest))
      FileUtils.mv("#{@path}/#{zip_file}", zip_dest)

      # mv /tmp/jets/demo/stage/zips/code.zip /tmp/jets/demo/stage/zips/code-a8a604aa.zip
      FileUtils.mv(zip_dest, md5_dest)

      file_size = number_to_human_size(File.size(md5_dest))
      puts "Zip file created at: #{md5_dest.colorize(:green)} (#{file_size})"
    end

    # /tmp/jets/demo/stage/zips/code.zip
    def zip_dest
      stage_area, filename = File.dirname(@path), File.basename(@path)
      zip_area = stage_area + '/zips' # /tmp/jets/demo/stage/zips
      zip_file = filename + '.zip' # code.zip
      "#{zip_area}/#{zip_file}" # /tmp/jets/demo/stage/zips/code.zip
    end

    def zip_file
      File.basename(zip_dest)
    end

    # /tmp/jets/demo/stage/zips/code-SHA.zip
    def md5_dest
      zip_dest.sub(".zip", "-#{@checksum}.zip")
    end

    def md5_name
      File.basename(md5_dest)
    end
  end
end