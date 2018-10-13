class Jets::Builders
  class Md5Zip
    include ActionView::Helpers::NumberHelper # number_to_human_size
    include Util

    def initialize(path)
      @path = path
    end

    def create
      headline "Creating zip file for #{@path}"


    end

    def create2
      headline "Creating zip file."
      temp_code_zipfile = "#{Jets.build_root}/code/code-temp.zip"
      FileUtils.mkdir_p(File.dirname(temp_code_zipfile))

      # Use fake if testing CloudFormation only
      if @fake
        hello_world = "/tmp/hello.js"
        puts "Uploading tiny #{hello_world} file to S3 for quick testing.".colorize(:red)
        code = IO.read(File.expand_path("../node-hello.js", __FILE__))
        IO.write(hello_world, code)
        command = "zip --symlinks -rq #{temp_code_zipfile} #{hello_world}"
      else
        # https://serverfault.com/questions/265675/how-can-i-zip-compress-a-symlink
        command = "cd #{full(tmp_code)} && zip --symlinks -rq #{temp_code_zipfile} ."
      end

      sh(command)

      # we can get the md5 only after the file has been created
      md5 = Digest::MD5.file(temp_code_zipfile).to_s[0..7]
      md5_zip_dest = "#{Jets.build_root}/code/code-#{md5}.zip"
      FileUtils.mkdir_p(File.dirname(md5_zip_dest))
      FileUtils.mv(temp_code_zipfile, md5_zip_dest)
      # mv /tmp/jets/demo/code/code-temp.zip /tmp/jets/demo/code/code-a8a604aa.zip

      file_size = number_to_human_size(File.size(md5_zip_dest))
      puts "Zip file with code and bundled linux ruby created at: #{md5_zip_dest.colorize(:green)} (#{file_size})"

      # Save state
      IO.write("#{Jets.build_root}/code/current-md5-filename.txt", md5_zip_dest)
      # Much later: ship, base_child_builder need set an s3_key which requires
      # the md5_zip_dest.
      # It is a pain to pass this all the way up from the
      # CodeBuilder class.
      # Let's store the "/tmp/jets/demo/code/code-a8a604aa.zip" into a
      # file that can be read from any places where this is needed.
      # Can also just generate a "fake file" for specs
    end
  end
end