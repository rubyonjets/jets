require "fileutils"
require "open-uri"
require "colorize"

class Jets::Build
  RUBY_URL = 'https://s3.amazonaws.com/boltops-gems/rubies/ruby-2.4.2-linux-x86_64.tar.gz'.freeze

  class TravelingRuby
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

      FileUtils.mkdir_p(Jets.tmp_build)
      Dir.chdir(Jets.tmp_build) do
        # These commands run from Jets.tmp_build
        get_linux_ruby
        copy_gemfiles
        bundle_install

        configure_bundler
        copy_bundled_to_project
      end
    end

    def jets_ruby_version
      RUBY_URL.match(/ruby-(\d+\.\d+\.\d+)-linux/)[1] # 2.4.2
    end

    def check_ruby_version
      if RUBY_VERSION != jets_ruby_version
        puts "You are using ruby version #{RUBY_VERSION}."
        abort("You must use ruby #{jets_ruby_version} to build the project because it's what Jets uses.".colorize(:red))
      end
    end

    def get_linux_ruby
      if File.exist?(bundled_ruby_dest)
        puts "Precompiled Linix Ruby #{jets_ruby_version} already downloaded at #{Jets.tmp_build}/#{bundled_ruby_dest}."
      else
        download_linux_ruby
      end
    end

    def download_linux_ruby
      puts "Downloading jets ruby from #{RUBY_URL}."

      File.open(ruby_tarfile, 'wb') do |saved_file|
        # the following "open" is provided by open-uri
        open(RUBY_URL, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end

      puts 'Download complete.'
    end

    def unpack_jets_ruby
      puts 'Unpacking jets ruby.'

      FileUtils.mkdir_p(bundled_ruby_dest)

      success = system("tar -xzf #{ruby_tarfile} -C #{bundled_ruby_dest}")
      abort('Unpacking jets ruby failed') unless success
      puts 'Unpacking jets ruby successful.'

      puts 'Removing tar.'
      FileUtils.rm_f(ruby_tarfile)
    end

    def copy_gemfiles
      FileUtils.cp("#{full_project_path}Gemfile", "#{Jets.tmp_build}/")
      FileUtils.cp("#{full_project_path}Gemfile.lock", "#{Jets.tmp_build}/")
    end

    def bundle_install
      puts 'Installing bundle.'
      require "bundler" # dynamicaly require bundler so user can use any bundler
      Bundler.with_clean_env do
        success = system(
          "cd #{Jets.tmp_build} && " \
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
      puts "Moving gemfiles into #{Jets.tmp_build}/#{bundled_gems_dest}/"
      FileUtils.mv("Gemfile", "#{bundled_gems_dest}/")
      FileUtils.mv("Gemfile.lock", "#{bundled_gems_dest}/")

      bundle_config_path = "#{bundled_gems_dest}/.bundle/config"
      puts "Generating #{Jets.tmp_build}/#{bundle_config_path}"
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
        puts "Removing current bundled from project"
        FileUtils.rm_rf("#{full_project_path}bundled")
      end
      puts "Copying #{Jets.tmp_build}/bundled folder to your project."
      FileUtils.cp_r("#{Jets.tmp_build}/bundled", full_project_path)
    end

    def bundled_ruby_dest
      "bundled/ruby"
    end

    def bundled_gems_dest
      "bundled/gems"
    end

    def ruby_tarfile
      File.basename(RUBY_URL)
    end
  end
end
