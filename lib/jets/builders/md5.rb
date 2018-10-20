require 'digest'

# Resolves the chicken-and-egg problem with md5 checksums. The handlers need
# to reference files with the md5 checksum.  The files are the:
#
#   jets/code/rack-checksum.zip
#   jets/code/bundled-checksum.zip
#
# We compute the checksums before we generate the node shim handlers.
class Jets::Builders
  class Md5
    @@checksums = {}
    def self.compute!
      @@checksums = new.compute
    end

    def self.checksums
      @@checksums
    end

    def compute
      paths = %w[
        stage/code
        stage/bundled
        stage/rack
      ]
      checksums = {}
      paths.each do |path|
        full_path = "#{Jets.build_root}/#{path}"
        checksums[path] = dir(full_path)
      end
      checksums
    end

    def dir(path)
      files = Dir["#{path}/**/*"]
      files.reject! { |f| File.directory?(f) }
           .reject! { |f| File.symlink?(f) }
      content = files.map do |f|
        Digest::MD5.file(f).to_s[0..7]
      end.join
      md5 = Digest::MD5.new
      md5.update(content)
      md5.hexdigest.to_s[0..7]
    end
  end
end
