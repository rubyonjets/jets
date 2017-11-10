require "fileutils"
require "open-uri"
require "colorize"
require "socket"
require "net/http"

class Jets::Build
  RUBY_URL = 'https://s3.amazonaws.com/boltops-gems/rubies/ruby-2.4.2-linux-x86_64.tar.gz'.freeze

  class LinuxRuby
    attr_reader :full_project_path
    def initialize
      # Expanding to the full path and capture now.
      # Dir.chdir gets called later and we'll lose this info.
      @full_project_path = File.expand_path(Jets.root) + "/"
    end

    def build
      if File.exist?("#{Jets.tmp_build}/bundled")
        puts "The #{Jets.tmp_build}/bundled folder exists. Incrementally re-building the bundle.  To fully rebundle: rm -rf #{Jets.tmp_build}/bundled"
      end
      check_ruby_version

      FileUtils.mkdir_p(Jets.tmp_build) # /tmp/jets_build/demo
      # These commands run from within Jets.tmp_build
      Dir.chdir(Jets.tmp_build) do
        bundle_install # installs current target gems: both compiled and non-compiled
        get_linux_ruby
        get_linux_gems
        # finally copy project and bundled folder into this project
        copy_project
        # copy_bundled_to_project
      end
    end

    def get_linux_gems
      # Example paths:
      #   bundled/gems/ruby/2.4.0/extensions/x86_64-darwin-16/2.4.0-static/nokogiri-1.8.1
      #   bundled/gems/ruby/2.4.0/extensions/x86_64-darwin-16/2.4.0-static/byebug-9.1.0
      #   bundled/gems/ruby/2.4.0/extensions/x86_64-linux/2.4.0-static/nokogiri-1.8.1
      compiled_gem_paths = Dir.glob("bundled/gems/ruby/*/extensions/*darwin*/*/*").to_a
      gem_names = compiled_gem_paths.map { |p| gem_name(p) }

      # Exits early if not all the linux gems are available
      # It better to error now then later on Lambda
      # Provide users with instructions on how to compile gems
      check_availability(gem_names)

      gem_names.each do |gem_name|
        download_linux_gem(gem_name)
      end
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
        puts "Some ways to fix this:"
        puts "  1. Build this jets project on an Amazon Lambda based EC2 Instance."
        puts "  2. Add it to boltopslabs/lambda-gems and submit a pull request."
        puts "  3. Configure jets to lookup your own pre-compiled binaries."
        puts
        puts "More info: http://rubyjets.org/lambda-gems"
        exit
      end
    end

    def url_exists?(url)
      url = URI.parse("http://www.someurl.lc/")
      req = Net::HTTP.new(url.host, url.port)
      res = req.request_head(url.path)
      true
    rescue SocketError => e
      false
    end

    def gem_url(gem_name)
      # TODO: make boltops-gems downloads s3 url configurable
      "https://s3.amazonaws.com/boltops-gems/gems/#{gem_name}-x86_64-linux}.tar.gz"
    end

    # Input: bundled/gems/ruby/2.4.0/extensions/x86_64-darwin-16/2.4.0-static/byebug-9.1.0
    # Output: byebug-9.1.0
    def gem_name(path)
      File.basename(path)
    end

    # gem_name: byebug-9.1.0
    def download_linux_gem(gem_name)
      url = gem_url(gem_name)
      dest = File.basename(url)
      download_url(url, dest)
    end

    # Installs gems on the current target system: both compiled and non-compiled.
    # If user is on a macosx machine, macosx gems will be installed.
    # If user is on a linux machine, linux gems will be installed.
    #
    # Copies Gemfile* to /tmp/jets_builds/demo/bundled folder and installs
    # gems with bundle install from there.
    #
    # We take the time to copy Gemfile and bundle into a separate directory
    # because it gets left around to act as a 'cache'.  So, when the builds the
    # project gets built again not all the gems from get installed from the
    # beginning.
    def bundle_install
      puts 'Installing bundle.'
      copy_gemfiles

      require "bundler" # dynamically require bundler so user can use any bundler
      Bundler.with_clean_env do
        # cd /tmp/jets_build/demo/bundled
        success = system(
          "cd #{full("bundled")} && " \
          "env BUNDLE_IGNORE_CONFIG=1 bundle install --path gems --without development test"
        )

        abort('Bundle install failed, exiting.') unless success
      end

      configure_bundler
      puts 'Bundle install success.'
    end

    def copy_gemfiles
      FileUtils.mkdir_p(full("bundled"))
      FileUtils.cp("#{@full_project_path}Gemfile", "#{full("bundled")}/Gemfile")
      FileUtils.cp("#{@full_project_path}Gemfile.lock", "#{full("bundled")}/Gemfile.lock")
    end

    # The wrapper script doesnt seem to work unless you move the gem files in the
    # bundled/gems folder and export it to BUNDLE_GEMFILE in the
    # wrapper script.
    def configure_bundler
      # This happens in /tmp/jets_build/demo
      # bundled_gems_dest: bundled/gems
      puts "Moving gemfiles into #{full(bundled_gems_dest)}/"
      FileUtils.mv("bundled/Gemfile", "#{bundled_gems_dest}/")
      FileUtils.mv("bundled/Gemfile.lock", "#{bundled_gems_dest}/")

      bundle_config_path = "#{bundled_gems_dest}/.bundle/config"
      puts "Generating #{full(bundle_config_path)}"
      FileUtils.mkdir_p(File.dirname(bundle_config_path))
      bundle_config =<<-EOL
BUNDLE_PATH: .
BUNDLE_WITHOUT: development test
BUNDLE_DISABLE_SHARED_GEMS: '1'
EOL
      IO.write(bundle_config_path, bundle_config)
    end

    # Copy project into temporarly directory. Do this so we can keep the project
    # directory untouched and we can also remove a bunch of needed files like
    # logs before zipping it up.
    def copy_project
      puts "Copying project to temporary folder to build it: #{temp_app_code}"
      FileUtils.rm_rf(temp_app_code)
      FileUtils.cp_r(@full_project_path, temp_app_code)
    end

    def check_ruby_version
      if RUBY_VERSION != jets_ruby_version
        puts "You are using ruby version #{RUBY_VERSION}."
        abort("You must use ruby #{jets_ruby_version} to build the project because it's what Jets uses.".colorize(:red))
      end
    end

    def jets_ruby_version
      RUBY_URL.match(/ruby-(\d+\.\d+\.\d+)-linux/)[1] # 2.4.2
    end

    def get_linux_ruby
      if File.exist?(bundled_ruby_dest)
        puts "Precompiled Linix Ruby #{jets_ruby_version} already downloaded at #{full(bundled_ruby_dest)}."
      else
        download_linux_ruby
        unpack_linux_ruby
      end
    end

    def download_linux_ruby
      puts "Downloading linux ruby from #{RUBY_URL}."
      download_url(RUBY_URL, ruby_tarfile)
      puts 'Download complete.'
    end

    def download_url(source, dest)
      File.open(dest, 'wb') do |saved_file|
        # the following "open" is provided by open-uri
        open(source, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end
    end

    def unpack_linux_ruby
      puts 'Unpacking linux ruby.'

      FileUtils.mkdir_p(bundled_ruby_dest)

      success = system("tar -xzf #{ruby_tarfile} -C #{bundled_ruby_dest}")
      abort('Unpacking linux ruby failed') unless success
      puts 'Unpacking linux ruby successful.'

      puts 'Removing tar.'
      FileUtils.rm_f(ruby_tarfile)
    end

    def copy_bundled_to_project
      if File.exist?("#{full_project_path}bundled")
        puts "Removing current bundled from project"
        FileUtils.rm_rf("#{full_project_path}bundled")
      end
      puts "Copying #{Jets.tmp_build}/bundled folder to your project."
      FileUtils.cp_r("#{Jets.tmp_build}/bundled", full_project_path)
    end

    def full(relative_path)
      "#{Jets.tmp_build}/#{relative_path}"
    end

    # Group all the path settings together here
    def temp_app_code
      "app_code"
    end

    def bundled_ruby_dest(full=false)
      "bundled/ruby"
    end

    def bundled_gems_dest(full=false)
      "bundled/gems"
    end

    def ruby_tarfile
      File.basename(RUBY_URL)
    end
  end
end
