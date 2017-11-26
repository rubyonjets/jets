require "fileutils"
require "open-uri"
require "colorize"
require "socket"
require "net/http"
require "action_view"

# Builds bundled Linux ruby and shim handlers
class Jets::Builders
  class CodeBuilder
    RUBY_URL = 'https://s3.amazonaws.com/lambdagems/rubies/ruby-2.4.2-linux-x86_64.tar.gz'.freeze

    include ActionView::Helpers::NumberHelper # number_to_human_size
    attr_reader :full_project_path
    def initialize
      # Expanding to the full path and capture now.
      # Dir.chdir gets called later and we'll lose this info.
      @full_project_path = File.expand_path(Jets.root) + "/"
    end

    def build
      clean_start # cleans out non-cached files like code-*.zip in Jets.build_roots

      if File.exist?("#{Jets.build_root}/bundled")
        puts "The #{Jets.build_root}/bundled folder exists. Incrementally re-building the bundle.  To fully rebundle: rm -rf #{Jets.build_root}/bundled"
      end
      check_ruby_version

      FileUtils.mkdir_p(Jets.build_root) # /tmp/jets/demo
      # These commands run from within Jets.build_root
      Dir.chdir(Jets.build_root) do
        bundle_install # installs current target gems: both compiled and non-compiled
        get_linux_ruby
        get_linux_gems
        # finally copy project and bundled folder into this project
      end

      copy_project
      # Easier reason about the logic by when runrning these commands in
      # the tmp_app_root itself
      Dir.chdir(full(tmp_app_root)) do
        finalize_project
      end
    end

    # Most files are kept around after the build process for inspection and
    # debugging. So we have to clean out the files. But we only want to clean ou
    # some of the files.
    #
    # Cleans out non-cached files like code-*.zip in Jets.build_root
    # for a clean start.
    #
    def clean_start
      Dir.glob("#{Jets.build_root}/code/code-*.zip").each { |f| FileUtils.rm_f(f) }
    end

    def finalize_project
      clean_project
      # clean_project might remove bundled, .bundle/config, handlers, etc
      # if it is set in .gitignore of the project so always generate
      # after the project has been cleaned
      generate_node_shims
      copy_bundle_config
      copy_bundled_to_project
      create_zip_file
    end

    # Copy project into temporarly directory. Do this so we can keep the project
    # directory untouched and we can also remove a bunch of needed files like
    # logs before zipping it up.
    def copy_project
      puts "Copying project to temporary folder to build it: #{full(tmp_app_root)}"
      FileUtils.rm_rf(full(tmp_app_root)) # remove current app_root folder
      move_node_modules(Jets.root, Jets.build_root)
      begin
        FileUtils.cp_r(@full_project_path, full(tmp_app_root))
      ensure
        move_node_modules(Jets.build_root, Jets.root) # move node_modules directory back
      end
    end

    # Move the node modules to the tmp build folder to speed up project copying.
    # A little bit risk because a ctrl-c in the middle of the project copying
    # results in a missing node_modules but user can easily rebuild that.
    #
    # Tesing shows 6.623413 vs 0.027754 speed improvement.
    def move_node_modules(source_folder, dest_folder)
      source = "#{source_folder}/node_modules"
      dest = "#{dest_folder}/node_modules"
      if File.exist?(source)
        FileUtils.mv(source, dest)
      end
    end

    # Because we're removing files (something dangerous) use full paths.
    def clean_project
      puts "Cleaning up: removing ignored files before packaging zipfile."
      excludes.each do |exclude|
        exclude = exclude.sub(%r{^/},'') # remove leading slash
        remove_path = "#{full(tmp_app_root)}/#{exclude}"
        FileUtils.rm_rf(remove_path)
        puts "  rm -rf #{remove_path}"
      end
    end

    def generate_node_shims
      # Crucial that the Dir.pwd is in the tmp_app_root because for
      # Jets::Builders::app_files because Jets.boot set ups
      # autoload_paths and this is how project classes are loaded.
      Jets::Builders::app_files.each do |path|
        handler = Jets::Builders::HandlerGenerator.new(path)
        handler.generate
      end
    end

    def copy_bundle_config
      # Override project's .bundle/config and ensure that .bundle/config matches
      # at these 2 spots:
      #   app_root/.bundle/config
      #   bundled/gems/.bundle/config
      new_bundle_config = "#{Jets.build_root}/.bundle/config"
      app_bundle_config = "#{full(tmp_app_root)}/.bundle/config"
      FileUtils.mkdir_p(File.dirname(app_bundle_config))
      FileUtils.cp(new_bundle_config, app_bundle_config)
    end

    def copy_bundled_to_project
      app_root_bundled = "#{full(tmp_app_root)}/bundled"
      if File.exist?(app_root_bundled)
        puts "Removing current bundled from project"
        FileUtils.rm_rf(app_root_bundled)
      end
      # Leave #{Jets.build_root}/bundled behind to act as cache
      FileUtils.cp_r("#{Jets.build_root}/bundled", app_root_bundled)
    end

    def create_zip_file
      puts "Creating zip file."
      temp_code_zipfile = "#{Jets.build_root}/code/code-temp.zip"
      FileUtils.mkdir_p(File.dirname(temp_code_zipfile))

      command = "cd #{full(tmp_app_root)} && zip -rq #{temp_code_zipfile} ."
      success = system(command)
      puts command
      # zip -rq /tmp/jets/demo/code/code-temp.zip app_root
      abort("Fail creating app code zipfile") unless success

      # we can get the md5 only after the file has been created
      md5 = Digest::MD5.file(temp_code_zipfile).to_s[0..7]
      md5_zip_dest = "#{Jets.build_root}/code/code-#{md5}.zip"
      FileUtils.mkdir_p(File.dirname(md5_zip_dest))
      FileUtils.mv(temp_code_zipfile, md5_zip_dest)
      # mv /tmp/jets/demo/code/code-temp.zip /tmp/jets/demo/code/code-a8a604aa.zip

      abort("Creating zip failed, exiting.") unless success

      file_size = number_to_human_size(File.size(md5_zip_dest))
      puts "Zip file with code and bundled linux ruby created at: #{md5_zip_dest.colorize(:green)} (#{file_size})"

      IO.write("#{Jets.build_root}/code/current-md5-filename.txt", md5_zip_dest)
      # Much later: ship, base_child_builder need set an s3_key which requires
      # the md5_zip_dest.
      # It is a pain to pass this all the way up from the
      # CodeBuilder class.
      # Let's store the "/tmp/jets/demo/code/code-a8a604aa.zip" into a
      # file that can be read from any places where this is needed.
      # Can also just generate a "fake file" for specs
    end

    def get_linux_gems
      fetcher = GemFetcher.new
      fetcher.run
    end

    # Installs gems on the current target system: both compiled and non-compiled.
    # If user is on a macosx machine, macosx gems will be installed.
    # If user is on a linux machine, linux gems will be installed.
    #
    # Copies Gemfile* to /tmp/jetss/demo/bundled folder and installs
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
        # cd /tmp/jets/demo/bundled
        success = system(
          "cd #{Jets.build_root} && " \
          "env BUNDLE_IGNORE_CONFIG=1 bundle install --path bundled/gems --without development test"
        )

        abort('Bundle install failed, exiting.') unless success
      end

      puts 'Bundle install success.'
    end

    def copy_gemfiles
      FileUtils.mkdir_p(full("bundled"))
      FileUtils.cp("#{@full_project_path}Gemfile", "#{Jets.build_root}/Gemfile")
      FileUtils.cp("#{@full_project_path}Gemfile.lock", "#{Jets.build_root}/Gemfile.lock")
    end

    def excludes
      excludes = %w[.git tmp log spec]
      excludes += get_excludes("#{full(tmp_app_root)}/.gitignore")
      excludes += get_excludes("#{full(tmp_app_root)}/.dockerignore")
      excludes = excludes.reject do |p|
        jetskeep.find do |keep|
          p.include?(keep)
        end
      end
      excludes
    end

    def get_excludes(file)
      path = file
      return [] unless File.exist?(path)

      exclude = File.read(path).split("\n")
      exclude.map {|i| i.strip}.reject {|i| i =~ /^#/ || i.empty?}
      # IE: ["/handlers", "/bundled*", "/vendor/jets]
    end

    # We clean out ignored files pretty aggressively. So provide
    # a way for users to keep files from being cleaned ou.
    def jetskeep
      defaults = %w[pack handlers]
      path = Jets.root + ".jetskeep"
      return defaults unless path.exist?

      keep = path.read.split("\n")
      keep = keep.map {|i| i.strip}.reject {|i| i =~ /^#/ || i.empty?}
      (defaults + keep).uniq
    end

    def check_ruby_version
      if RUBY_VERSION != jets_ruby_version
        puts "You are using ruby version #{RUBY_VERSION}."
        abort("You must use ruby #{jets_ruby_version} to build the project because it's what Jets uses.".colorize(:red))
      end
    end

    def jets_ruby_version
      RUBY_URL.match(/ruby-(\d+\.\d+\.\d+)-/)[1]
    end

    def get_linux_ruby
      if File.exist?(bundled_ruby_dest)
        puts "Precompiled Linux Ruby #{jets_ruby_version} already downloaded at #{full(bundled_ruby_dest)}."
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
      FileUtils.mkdir_p(File.dirname(dest)) # ensure parent folder exists

      File.open(dest, 'wb') do |saved_file|
        # the following "open" is provided by open-uri
        # TODO: remove OpenSSL::SSL::VERIFY_NONE hack. Figure out how to install ssl cert properly
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

    # Provide pretty clear way to desinate full path.
    # full("bundled") => /tmp/jets/demo/bundled
    def full(relative_path)
      "#{Jets.build_root}/#{relative_path}"
    end

    # Group all the path settings together here
    def self.tmp_app_root
      Jets::Builders::tmp_app_root
    end

    def tmp_app_root
      self.class.tmp_app_root
    end

    def bundled_ruby_dest(full=false)
      "bundled/ruby"
    end

    def ruby_tarfile
      File.basename(RUBY_URL)
    end
  end
end
