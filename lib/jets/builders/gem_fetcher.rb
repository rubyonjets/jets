class Jets::Builders
  class GemFetcher
    def run
      # If there are subfolders compiled_gem_paths might have files deeper
      # in the directory tree.  So lets grab the gem name and figure out the
      # unique paths of the compiled gems from there.
      gem_names = compiled_gem_paths.map { |p| gem_name_from_path(p) }.uniq

      # Exits early if not all the linux gems are available
      # It better to error now then later on Lambda
      # Provide users with instructions on how to compile gems
      check_availability(gem_names)

      gem_names.each do |gem_name|
        get_linux_gem(gem_name)
        get_linux_library(gem_name)
      end
    end

    def compiled_gem_paths
      # We only want to check for darwin extensions.
      # If the user is compiling native extensions on a linux target
      # we directly upload them to Lambda.
      #
      # Example paths:
      #   bundled/gems/ruby/2.5.0/extensions/x86_64-darwin-16/2.5.0-static/nokogiri-1.8.1
      #   bundled/gems/ruby/2.5.0/extensions/x86_64-darwin-16/2.5.0-static/byebug-9.1.0
      #   bundled/gems/ruby/2.5.0/extensions/x86_64-linux/2.5.0-static/nokogiri-1.8.1
      Dir.glob("#{Jets.build_root}/bundled/gems/ruby/*/extensions/*darwin*/**/*.{so,bundle}")
    end

    # Input: bundled/gems/ruby/2.5.0/extensions/x86_64-darwin-16/2.5.0-static/byebug-9.1.0
    # Output: byebug-9.1.0
    def gem_name_from_path(path)
      regexp = /gems\/ruby\/\d+\.\d+\.\d+\/extensions\/.*?\/.*?\/(.*?)\//
      gem_name = path.match(regexp)[1]
    end

    # Input: "https://s3.amazonaws.com/lambdagems/gems/2.5.0/byebug/system.tgz"
    # Output: byebug
    def versionless_gem_name(gem_name)
      gem_name.sub(/-\d+\.\d+\.\d+.*/,'')
    end

    # Downloads and extracts the linux gem into the proper directory.
    # Extracts to: bundled/gems/ruby
    # The downloaded tarball already has the full directory structure
    # with the ruby version, example:
    #   2.5.0/extensions/x86_64-darwin-16/2.5.0-static/byebug-9.1.0
    # So all we need to do is extract the tarball into bundled/gems/ruby.
    #
    # gem_name: byebug-9.1.0
    def get_linux_gem(gem_name)
      # download - also move to /tmp/jets/demo/compiled_gems folder
      url = gem_url(gem_name)
      versionless_gem_name = versionless_gem_name(gem_name)
      tarball = "#{Jets.build_root}/extensions/#{versionless_gem_name}/#{File.basename(url)}"
      if File.exist?(tarball)
        puts "Compiled gem already downloaded #{tarball}"
      else
        download_file(url, tarball)
      end

      extract_gem(tarball)
    end

    def download_file(source_url, dest)
      puts "Downloading: #{source_url}"
      FileUtils.mkdir_p(File.dirname(dest)) # ensure parent folder exists

      File.open(dest, 'wb') do |saved_file|
        # the following "open" is provided by open-uri
        # TODO: remove OpenSSL::SSL::VERIFY_NONE hack. Figure out how to install ssl cert properly
        open(source_url, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end
    end

    # The gem might required shared .so files.  We check each gem
    def get_linux_library(gem_name)
      system_url = gem_system_url(gem_name)

      if url_exists?(system_url)
        versionless_gem_name = versionless_gem_name(gem_name)
        system_tarball = "#{Jets.build_root}/extensions/#{versionless_gem_name}/system.tgz"
        if File.exist?(system_tarball)
          puts "Compiled library already downloaded #{system_tarball}"
        else
          download_file(system_url, system_tarball)
        end

        extract_library(system_tarball)
      end
    end

    def extract_library(tarball)
      bundled_folder = "#{Jets.build_root}/bundled"
      puts "Unpacking compiled library #{tarball} into #{bundled_folder}"

      FileUtils.mkdir_p(bundled_folder)
      success = system("tar -xzf #{tarball} -C #{bundled_folder}")
      abort("Unpacking library #{tarball} failed") unless success
      puts "Unpacking library successful."
    end

    def extract_gem(tarball)
      gems_ruby_folder = "#{Jets.build_root}/bundled/gems/ruby"
      puts "Unpacking compiled gem #{tarball} into #{gems_ruby_folder}"

      FileUtils.mkdir_p(gems_ruby_folder)
      success = system("tar -xzf #{tarball} -C #{gems_ruby_folder}")
      abort("Unpacking gem #{tarball} failed") unless success
      puts "Unpacking gem successful."
    end

    # We check all the availability before even downloading so we can provide a
    # full list of gems they might want to research all at once instead of incrementally
    def check_availability(gems)
      availabilities = gems.inject({}) do |hash, gem_name|
        exist = url_exists?(gem_url(gem_name))
        hash[gem_name] = exist
        hash.merge(hash)
      end

      all_available = availabilities.values.all? {|v| v }
      unless all_available
        puts "Your project requires some pre-compiled Linux gems that are not yet available as a pre-compiled lambda gem.  The build process will not continue because there's no point wasting your time deploying to Lambda and finding out later."
        puts "The unavailable gems are:"
        availabilities.each do |gem_name, available|
          next if available
          puts "  #{gem_name}"
        end
        puts <<-EOL
How to fix this:

  1. Build your jets project on an Amazon Lambda based EC2 Instance and compile your own gems with the proper shared libaries.
  2. Configure jets to lookup your own pre-compiled gems url.
  3. Add the the required gems to boltopslabs/lambdagems and submit a pull request.

More info: http://lambdagems.com
EOL
        exit
      end
    end

    # Example url:
    #   https://s3.amazonaws.com/lambdagems/gems/2.5.0/byebug/byebug-9.1.0-x86_64-linux.tar.gz
    def url_exists?(url)
      url = URI.parse(url)
      req = Net::HTTP.new(url.host, url.port).tap do |http|
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      res = req.request_head(url.path)
      res.code == "200"
    rescue SocketError, OpenURI::HTTPError
      false
    end

    # TODO: make lambdagems downloads s3 url configurable
    def lambdagems_url
      "https://s3.amazonaws.com/lambdagems"
    end

    # gem_name: byebug-9.1.0
    # Example url:
    #   https://s3.amazonaws.com/lambdagems/gems/2.5.0/byebug/byebug-9.1.0-x86_64-linux.tar.gz
    def gem_url(gem_name)
      folder = gem_name.gsub(/-(\d+\.\d+\.\d+.*)/,'') # folder: byebug
      "#{lambdagems_url}/gems/#{RUBY_VERSION}/#{folder}/#{gem_name}-x86_64-linux.tar.gz"
    end

    # If there's a  system.tgz then it is the same folder as the tarball gem.
    def gem_system_url(gem_name)
      gem_url = gem_url(gem_name)
      File.dirname(gem_url) + "/system.tgz"
    end
  end
end
