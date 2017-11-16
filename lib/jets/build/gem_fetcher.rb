class Jets::Build
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
      end
    end

    def compiled_gem_paths
      # We only want to check for darwin extensions.
      # If the user is compiling native extensions on a linux target
      # we directly upload them to Lambda.
      #
      # Example paths:
      #   bundled/gems/ruby/2.4.0/extensions/x86_64-darwin-16/2.4.0-static/nokogiri-1.8.1
      #   bundled/gems/ruby/2.4.0/extensions/x86_64-darwin-16/2.4.0-static/byebug-9.1.0
      #   bundled/gems/ruby/2.4.0/extensions/x86_64-linux/2.4.0-static/nokogiri-1.8.1
      Dir.glob("#{Jets.build_root}/bundled/gems/ruby/*/extensions/*darwin*/**/*.{so,bundle}")
    end

    # Input: bundled/gems/ruby/2.4.0/extensions/x86_64-darwin-16/2.4.0-static/byebug-9.1.0
    # Output: byebug-9.1.0
    def gem_name_from_path(path)
      regexp = /gems\/ruby\/\d+\.\d+\.\d+\/extensions\/.*?\/.*?\/(.*?)\//
      gem_name = path.match(regexp)[1]
    end

    # Downloads and extracts the linux gem into the proper directory.
    # Extracts to: bundled/gems/ruby
    # The downloaded tarball already has the full directory structure
    # with the ruby version, example:
    #   2.4.0/extensions/x86_64-darwin-16/2.4.0-static/byebug-9.1.0
    # So all we need to do is extract the tarball into bundled/gems/ruby.
    #
    # gem_name: byebug-9.1.0
    def get_linux_gem(gem_name)
      # download - also move to /tmp/jets/demo/compiled_gems folder
      url = gem_url(gem_name)
      tarball = "#{Jets.build_root}/extensions/#{File.basename(url)}"
      if File.exist?(tarball)
        puts "Compiled gem already downloaded #{tarball}"
      else
        download_gem(url, tarball)
      end

      extract_gem(tarball)
    end

    def extract_gem(tarball)
      # extract
      gems_ruby_folder = "#{Jets.build_root}/bundled/gems/ruby"
      puts "Unpacking compiled gem #{tarball} into #{gems_ruby_folder}"

      success = system("tar -xzf #{tarball} -C #{gems_ruby_folder}")
      abort("Unpacking gem #{tarball} failed") unless success
      puts "Unpacking gem #{tarball} successful."
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
        puts "How to fix this:"
        puts "  1. Build your jets project on an Amazon Lambda based EC2 Instance."
        puts "  2. Add the your required gems to boltopslabs/lambdagems and submit a pull request."
        puts "  3. Configure jets to lookup your own pre-compiled gems url."
        puts
        puts "More info: http://rubyonjets.com/lambdagems"
        exit
      end
    end

    def download_gem(source, dest)
      FileUtils.mkdir_p(File.dirname(dest)) # ensure parent folder exists

      File.open(dest, 'wb') do |saved_file|
        # the following "open" is provided by open-uri
        # TODO: remove OpenSSL::SSL::VERIFY_NONE hack. Figure out how to install ssl cert properly
        open(source, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end
    end

    # Example url:
    #   https://s3.amazonaws.com/boltops-gems/gems/2.4.2/byebug/byebug-9.1.0-x86_64-linux.tar.gz
    def url_exists?(url)
      puts "Checking url: #{url}"
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

    # gem_name: byebug-9.1.0
    # Example url:
    #   https://s3.amazonaws.com/boltops-gems/gems/2.4.2/byebug/byebug-9.1.0-x86_64-linux.tar.gz
    def gem_url(gem_name)
      # TODO: make boltops-gems downloads s3 url configurable
      folder = gem_name.gsub(/-(\d+\.\d+\.\d+.*)/,'') # folder byebug
      "https://s3.amazonaws.com/boltops-gems/gems/#{RUBY_VERSION}/#{folder}/#{gem_name}-x86_64-linux.tar.gz"
    end

  end
end
