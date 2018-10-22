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
    class << self
      @@checksums = {}
      def checksums
        @@checksums
      end

      def stage_paths
        paths = %w[stage/bundled]
        paths << "stage/rack" if File.exist?("#{Jets.root}rack")
        # Important to have stage/code at the end, since it will use the other
        # 'symlinked' folders to adjust the md5 hash.
        paths << "stage/code"
        paths
      end

      def compute!
        stage_paths.each do |path|
          @@checksums[path] = dir(path)
        end
        @@checksums
      end

      def dir(short_path)
        path = "#{Jets.build_root}/#{short_path}"
        files = Dir["#{path}/**/*"]
        files.reject! { |f| File.directory?(f) }
             .reject! { |f| File.symlink?(f) }
        content = files.map do |f|
          Digest::MD5.file(f).to_s[0..7]
        end.join

        # The stage/code md5 sha depends on the other 'symlinked' folders.
        if short_path == "stage/code"
          content += @@checksums.values.join
        end

        md5 = Digest::MD5.new
        md5.update(content)
        md5.hexdigest.to_s[0..7]
      end
    end
  end
end
