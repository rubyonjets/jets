require "fileutils"
require "open-uri"
require "colorize"

class Lam::Build
  TRAVELING_RUBY_VERSION = 'http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz'.freeze
  TEMP_BUILD_DIR = '/tmp/lam_build'.freeze

  class TravelingRuby
    def build
      check_ruby_version

      FileUtils.mkdir_p(TEMP_BUILD_DIR)
      copy_gemfiles

      Dir.chdir(TEMP_BUILD_DIR) do
        download_and_unpack_traveling_ruby(true)
        bundle_install
      end

      move_bundled_to_project
    end

    def check_ruby_version
      traveling_version = TRAVELING_RUBY_VERSION.match(/-((\d+)\.(\d+)\.(\d+))-/)[1]
      if RUBY_VERSION != traveling_version
        puts "You are using ruby version #{RUBY_VERSION}."
        abort("You must use ruby #{traveling_version} to build the project because it's what Traveling Ruby uses.".colorize(:red))
      end
    end

    def copy_gemfiles
      FileUtils.cp("#{Lam.root}Gemfile", "#{TEMP_BUILD_DIR}/")
      FileUtils.cp("#{Lam.root}Gemfile.lock", "#{TEMP_BUILD_DIR}/")
    end

    def download_and_unpack_traveling_ruby(force=false)
      if force or !File.exist?(bundled_ruby_dest)
        # provide full path for safety
        FileUtils.rm_rf("#{TEMP_BUILD_DIR}/#{bundled_ruby_dest}")
        download_traveling_ruby
        unpack_traveling_ruby
      else
        puts "Found traveling ruby in #{bundled_ruby_dest}, skipping download."
        return
      end
    end

    def download_traveling_ruby
      puts "Downloading traveling ruby from #{traveling_ruby_url}."

      File.open(traveling_ruby_tar_file, 'wb') do |saved_file|
        # the following "open" is provided by open-uri
        open(traveling_ruby_url, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end

      puts 'Download complete.'
    end

    def unpack_traveling_ruby
      puts 'Unpacking traveling ruby.'

      FileUtils.mkdir_p(bundled_ruby_dest)

      success = system("tar -xzf #{traveling_ruby_tar_file} -C #{bundled_ruby_dest}")
      abort('Unpacking traveling ruby failed') unless success
      puts 'Unpacking traveling ruby successful.'

      puts 'Removing tar.'
      FileUtils.rm_rf(traveling_ruby_tar_file)
    end

    def bundle_install
      puts 'Installing bundle.'
      require "bundler" # dynamicaly require bundler so user can use any bundler
      Bundler.with_clean_env do
        success = system(
          "cd #{TEMP_BUILD_DIR} && " \
          'env BUNDLE_IGNORE_CONFIG=1 bundle install --path bundled/gems --without development'
        )

        abort('Bundle install failed, exiting.') unless success
      end

      puts 'Bundle install success.'
    end

    def move_bundled_to_project
      if File.exist?("#{Lam.root}bundled")
        puts "Removing current bundled folder"
        FileUtils.rm_rf("#{Lam.root}bundled")
      end
      puts "Moving bundled ruby to your project."
      FileUtils.mv("#{TEMP_BUILD_DIR}/bundled", Lam.root)
    end

    def bundled_ruby_dest
      "bundled/ruby"
    end

    def traveling_ruby_url
      TRAVELING_RUBY_VERSION
    end

    def traveling_ruby_tar_file
      File.basename(traveling_ruby_url)
    end
  end
end
