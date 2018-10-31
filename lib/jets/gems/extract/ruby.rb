# Usage:
#
#   Jets::Gems::Extract::Ruby.new("2.5.0",
#     build_root: cache_area, # defaults to /tmp/lambdagem
#     dest: cache_area, # defaults to . (project_root)
#   ).run
#
module Jets::Gems::Extract
  class Ruby < Base
    class NotFound < RuntimeError; end

    def run
      say "Looking for #{full_ruby_name}"
      clean_downloads(:rubies) if @options[:clean]
      tarball_path = download_ruby
      unpack_tarball(tarball_path)
      say("Ruby #{full_ruby_name} unpacked at #{project_root}", :debug)
    end

    def download_ruby
      url = ruby_url
      tarball_dest = download_file(url, download_path(File.basename(url)))
      unless tarball_dest
        message = "Url: #{url} not found"
        if @options[:exit_on_error]
          say message
          # exit # TODO: ADD BACK IN
        else
          raise NotFound.new(message)
        end
      end
      say "Tarball downloaded to: #{tarball_dest}"
      tarball_dest
    end

    def download_path(filename)
      "#{@build_root}/downloads/rubies/#{filename}"
    end

    # If only the ruby version is given, then append ruby- in front. Otherwise
    # leave alone.
    #
    # Example:
    #
    #    2.5.0           -> ruby-2.5.0-linux-x86_64.tgz
    #    ruby-2.5.0      -> ruby-2.5.0-linux-x86_64.tgz
    #    test-ruby-2.5.0 -> test-ruby-2.5.0-linux-x86_64.tgz
    def full_ruby_name
      md = @name.match(/^(\d+\.\d+\.\d+)$/)
      if md
        ruby_version = md[1]
        "ruby-#{ruby_version}-linux-x86_64.tgz"
      else
        "#{@name}-linux-x86_64.tgz"
      end
    end

    def ruby_url
      "#{source_url}/rubies/#{full_ruby_name}"
    end
  end
end
