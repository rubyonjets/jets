require "fileutils"
require "open-uri"
require "colorize"

class Jets::Build
  TRAVELING_RUBY_URL = 'http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz'.freeze
  TEMP_BUILD_DIR = '/tmp/jets_build'.freeze

  class TravelingRuby
    attr_reader :full_project_path
    def initialize
      # Expanding to the full path and store at the beginning because this class
      # Users Dir.chdir and that changes possibility of capturing the project root
      # later.
      @full_project_path = File.expand_path(Jets.root) + "/"
    end

    def build
      if File.exist?("#{TEMP_BUILD_DIR}/bundled")
        puts "The #{TEMP_BUILD_DIR}/bundled folder exists. Incrementally re-building the bundle.  To fully rebundle: rm -rf #{TEMP_BUILD_DIR}/bundled"
      end

      check_ruby_version

      FileUtils.mkdir_p(TEMP_BUILD_DIR)
      Dir.chdir(TEMP_BUILD_DIR) do
        # These commands run from TEMP_BUILD_DIR
        get_traveling_ruby
        copy_gemfiles
        bundle_install
        configure_bundler
        copy_bundled_to_project
      end
    end

    def check_ruby_version
      traveling_version = TRAVELING_RUBY_URL.match(/-((\d+)\.(\d+)\.(\d+))-/)[1]
      if RUBY_VERSION != traveling_version
        puts "You are using ruby version #{RUBY_VERSION}."
        abort("You must use ruby #{traveling_version} to build the project because it's what Traveling Ruby uses.".colorize(:red))
      end
    end

    def get_traveling_ruby
      if File.exist?(bundled_ruby_dest)
        puts "Traveling Ruby already downloaded at #{bundled_ruby_dest}."
      else
        download_traveling_ruby
        unpack_traveling_ruby
      end
    end

    def download_traveling_ruby
      puts "Downloading traveling ruby from #{TRAVELING_RUBY_URL}."

      File.open(traveling_ruby_tar_file, 'wb') do |saved_file|
        # the following "open" is provided by open-uri
        open(TRAVELING_RUBY_URL, 'rb') do |read_file|
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
      FileUtils.rm_f(traveling_ruby_tar_file)
    end

    def copy_gemfiles
      FileUtils.cp("#{full_project_path}Gemfile", "#{TEMP_BUILD_DIR}/")
      FileUtils.cp("#{full_project_path}Gemfile.lock", "#{TEMP_BUILD_DIR}/")
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

    # The wrapper script doesnt work unless you move the gem files in the
    # bundled/gems folder and export it to BUNDLE_GEMFILE in the
    # wrapper script.
    def configure_bundler
      puts "Moving gemfiles into #{bundled_gems_dest}/"
      FileUtils.mv("Gemfile", "#{bundled_gems_dest}/")
      FileUtils.mv("Gemfile.lock", "#{bundled_gems_dest}/")

      bundle_config_path = "#{bundled_gems_dest}/.bundle/config"
      puts "Generating #{bundle_config_path}"
      FileUtils.mkdir_p(File.dirname(bundle_config_path))
      bundle_config =<<-EOL
BUNDLE_PATH: .
BUNDLE_WITHOUT: development
BUNDLE_DISABLE_SHARED_GEMS: '1'
EOL
      IO.write(bundle_config_path, bundle_config)
    end

    def copy_bundled_to_project
      if File.exist?("#{full_project_path}bundled")
        puts "Removing current #{full_project_path}bundled from project"
        FileUtils.rm_rf("#{full_project_path}bundled")
      end
      puts "Copying #{TEMP_BUILD_DIR}/bundled folder to your project."
      FileUtils.cp_r("#{TEMP_BUILD_DIR}/bundled", full_project_path)
    end

    def bundled_ruby_dest
      "bundled/ruby"
    end

    def bundled_gems_dest
      "bundled/gems"
    end

    def traveling_ruby_tar_file
      File.basename(TRAVELING_RUBY_URL)
    end
  end
end
