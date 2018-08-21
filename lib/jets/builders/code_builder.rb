require "fileutils"
require "open-uri"
require "colorize"
require "socket"
require "net/http"
require "action_view"
require "bundler" # for clean_old_submodules only

# Some important folders to help understand how jets builds a project:
#
# /tmp/jets: build root where different jets projects get built.
# /tmp/jets/project: each jets project gets built in a different subdirectory.
#
# The rest of the folders are subfolders under /tmp/jets/project:
#
# cache: Gemfile is here, this is where we run bundle install.
# cache/bundled/gems: Vendored gems that get created as part of bundled install.
#   Initially, macosx gems but then get replaced by linux gems where appropriate.
# cache/downloads/rubies: ruby tarballs.
# cache/downloads/gems: gem tarballs.
# app_root: Where project gets copied into in order for us to configure it.
# app_root/bundled/gems: Where vendored gems finally end up at.  The compiled
#   gems at this point are only linux gems.
# artifacts/code/code-md5sha.zip: code artifact that gets uploaded to lambda.
#
# Building Steps:
#
### Before copy
# * compile assets: easier to do this before the copy
#
### copy project
# * copy project: to app_root
#
### setup app_root project
# * clean project: remove log and ignored files to reduce size
# * reconfigure webpacker: config/webpacker.yml
# * generate node shims: handlers
#
### build bundled in cache area
# * bundle install: cache/bundled/gems
#
### setup bundled on app root from cache
# * copy bundled to app_root: app_root/bundled
# * extract linux ruby: cache/downloads/rubies:
#                       cache/bundled/rbenv, cache/bundled/linuxbrew
# * extract linux gems: cache/downloads/gems:
#                       cache/bundled/gems, cache/bundled/linuxbrew
# * setup bundled config: app_root/.bundle/config
#
### zip
# * create zip file
class Jets::Builders
  class CodeBuilder
    include Jets::Timing
    include ActionView::Helpers::NumberHelper # number_to_human_size

    attr_reader :full_project_path
    def initialize
      # Expanding to the full path and capture now.
      # Dir.chdir gets called later and we'll lose this info.
      @full_project_path = File.expand_path(Jets.root) + "/"
    end

    def build
      return create_zip_file(fake=true) if ENV['TEST_CODE'] # early return

      cache_check_message
      check_ruby_version

      clean_start
      compile_assets # easier to do before we copy the project
      copy_project
      Dir.chdir(full(tmp_app_root)) do
        # These commands run from project root
        start_app_root_setup
        bundle
        finish_app_root_setup
        create_zip_file
      end
    end
    time :build

    # Finds out of the app has polymorphic functions only and zero ruby functions.
    # In this case, we can skip a lot of the ruby related building and speed up the
    # deploy process.
    def poly_only?
      return true if ENV['POLY_ONLY'] # bypass to allow rapid development of handlers
      Jets::Commands::Build.poly_only?
    end

    def start_app_root_setup
      tidy_project
      reconfigure_development_webpacker
      reconfigure_ruby_version
      generate_node_shims
    end
    time :start_app_root_setup

    def finish_app_root_setup
      return if poly_only?

      copy_bundled_to_app_root
      setup_bundle_config
      extract_ruby
      extract_gems
    end
    time :finish_app_root_setup

    def lambdagem_options
      {
        s3: "lambdagems",
        build_root: cache_area, # used in lambdagem
        project_root: full(tmp_app_root), # used in gem_replacer and lambdagem
      }
    end

    def extract_ruby
      headline "Setting up a vendored copy of ruby."
      Lambdagem.log_level = :info
      Lambdagem::Extract::Ruby.new(Jets::RUBY_VERSION, lambdagem_options).run
    end

    def extract_gems
      headline "Replacing compiled gems with AWS Lambda Linux compiled versions."
      GemReplacer.new(Jets::RUBY_VERSION, lambdagem_options).run
    end

    # This happens in the current app directory not the tmp app_root for simplicity
    def compile_assets
      headline "Compling assets in current project directory"
      # Thanks: https://stackoverflow.com/questions/4195735/get-list-of-gems-being-used-by-a-bundler-project
      webpacker_loaded = Gem.loaded_specs.keys.include?("webpacker")
      return unless webpacker_loaded

      sh("yarn install")
      webpack_bin = File.exist?("#{Jets.root}bin/webpack") ?
          "bin/webpack" :
          `which webpack`.strip
      sh("JETS_ENV=#{Jets.env} #{webpack_bin}")
    end
    time :compile_assets

    # Cleans out non-cached files like code-*.zip in Jets.build_root
    # for a clean start. Also ensure that the /tmp/jets/project build root exists.
    #
    # Most files are kept around after the build process for inspection and
    # debugging. So we have to clean out the files. But we only want to clean out
    # some of the files.
    def clean_start
      Dir.glob("#{Jets.build_root}/code/code-*.zip").each { |f| FileUtils.rm_f(f) }
      FileUtils.mkdir_p(Jets.build_root) # /tmp/jets/demo
    end

    # Copy project into temporary directory. Do this so we can keep the project
    # directory untouched and we can also remove a bunch of unnecessary files like
    # logs before zipping it up.
    def copy_project
      headline "Copying current project directory to temporary build area: #{full(tmp_app_root)}"
      FileUtils.rm_rf(full(tmp_app_root)) # remove current app_root folder
      move_node_modules(Jets.root, Jets.build_root)
      begin
        FileUtils.cp_r(@full_project_path, full(tmp_app_root))
      ensure
        move_node_modules(Jets.build_root, Jets.root) # move node_modules directory back
      end
    end
    time :copy_project

    # Move the node modules to the tmp build folder to speed up project copying.
    # A little bit risky because a ctrl-c in the middle of the project copying
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
    def tidy_project
      headline "Tidying project: removing ignored files to reduce package size."
      excludes.each do |exclude|
        exclude = exclude.sub(%r{^/},'') # remove leading slash
        remove_path = "#{full(tmp_app_root)}/#{exclude}"
        FileUtils.rm_rf(remove_path)
        # puts "  rm -rf #{remove_path}" # uncomment to debug
      end
    end

    def generate_node_shims
      headline "Generating node shims in the handlers folder."
      # Crucial that the Dir.pwd is in the tmp_app_root because for
      # Jets::Builders::app_files because Jets.boot set ups
      # autoload_paths and this is how project classes are loaded.
      Jets::Commands::Build.app_files.each do |path|
        handler = Jets::Builders::HandlerGenerator.new(path)
        handler.generate
      end
    end

    # Bit hacky but this saves the user from accidentally forgetting to change this
    # when they deploy a jets project in development mode
    def reconfigure_development_webpacker
      return unless Jets.env.development?
      headline "Reconfiguring webpacker development settings for AWS Lambda."

      webpacker_yml = "#{full(tmp_app_root)}/config/webpacker.yml"
      return unless File.exist?(webpacker_yml)

      config = YAML.load_file(webpacker_yml)
      config["development"]["compile"] = false # force this to be false for deployment
      new_yaml = YAML.dump(config)
      IO.write(webpacker_yml, new_yaml)
    end

    # This is in case the user has a 2.5.x variant.
    # Force usage of ruby version that jets supports
    # The lambda server only has ruby 2.5.0 installed.
    def reconfigure_ruby_version
      ruby_version = "#{full(tmp_app_root)}/.ruby-version"
      IO.write(ruby_version, Jets::RUBY_VERSION)
    end

    def copy_bundled_to_app_root
      app_root_bundled = "#{full(tmp_app_root)}/bundled"
      if File.exist?(app_root_bundled)
        puts "Removing current bundled from project"
        FileUtils.rm_rf(app_root_bundled)
      end
      # Leave #{Jets.build_root}/bundled behind to act as cache
      FileUtils.cp_r("#{cache_area}/bundled", app_root_bundled)
    end

    def setup_bundle_config
      ensure_build_cache_bundle_config_exists!

      # Override project's .bundle/config and ensure that .bundle/config matches
      # at these 2 spots:
      #   app_root/.bundle/config
      #   bundled/gems/.bundle/config
      cache_bundle_config = "#{cache_area}/.bundle/config"
      app_bundle_config = "#{full(tmp_app_root)}/.bundle/config"
      FileUtils.mkdir_p(File.dirname(app_bundle_config))
      FileUtils.cp(cache_bundle_config, app_bundle_config)
    end

    # On circleci the "#{Jets.build_root}/.bundle/config" doesnt exist
    # this only happens with ssh debugging, not when the ci.sh script gets ran.
    # But on macosx it exists.
    # Dont know why this is the case.
    def ensure_build_cache_bundle_config_exists!
      text =<<-EOL
---
BUNDLE_PATH: "bundled/gems"
BUNDLE_WITHOUT: "development:test"
EOL
      bundle_config = "#{cache_area}/.bundle/config"
      FileUtils.mkdir_p(File.dirname(bundle_config))
      IO.write(bundle_config, text)
    end

    def create_zip_file(fake=nil)
      headline "Creating zip file."
      temp_code_zipfile = "#{Jets.build_root}/code/code-temp.zip"
      FileUtils.mkdir_p(File.dirname(temp_code_zipfile))

      # Use fake if testing CloudFormation only
      if fake
        hello_world = "/tmp/hello.js"
        puts "Uploading tiny #{hello_world} file to S3 for quick testing.".colorize(:red)
        code = IO.read(File.expand_path("../node-hello.js", __FILE__))
        IO.write(hello_world, code)
        command = "zip --symlinks -rq #{temp_code_zipfile} #{hello_world}"
      else
        # https://serverfault.com/questions/265675/how-can-i-zip-compress-a-symlink
        command = "cd #{full(tmp_app_root)} && zip --symlinks -rq #{temp_code_zipfile} ."
      end

      sh(command)

      # we can get the md5 only after the file has been created
      md5 = Digest::MD5.file(temp_code_zipfile).to_s[0..7]
      md5_zip_dest = "#{Jets.build_root}/code/code-#{md5}.zip"
      FileUtils.mkdir_p(File.dirname(md5_zip_dest))
      FileUtils.mv(temp_code_zipfile, md5_zip_dest)
      # mv /tmp/jets/demo/code/code-temp.zip /tmp/jets/demo/code/code-a8a604aa.zip

      file_size = number_to_human_size(File.size(md5_zip_dest))
      puts "Zip file with code and bundled linux ruby created at: #{md5_zip_dest.colorize(:green)} (#{file_size})"

      # Save state
      IO.write("#{Jets.build_root}/code/current-md5-filename.txt", md5_zip_dest)
      # Much later: ship, base_child_builder need set an s3_key which requires
      # the md5_zip_dest.
      # It is a pain to pass this all the way up from the
      # CodeBuilder class.
      # Let's store the "/tmp/jets/demo/code/code-a8a604aa.zip" into a
      # file that can be read from any places where this is needed.
      # Can also just generate a "fake file" for specs
    end
    time :create_zip_file

    def bundle
      clean_old_submodules
      bundle_install
    end
    time :bundle

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
      return if poly_only?

      headline "Bundling: running bundle install in cache area: #{cache_area}."

      copy_gemfiles

      require "bundler" # dynamically require bundler so user can use any bundler
      Bundler.with_clean_env do
        # cd /tmp/jets/demo
        sh(
          "cd #{cache_area} && " \
          "env BUNDLE_IGNORE_CONFIG=1 bundle install --path bundled/gems --without development test"
        )
      end

      puts 'Bundle install success.'
    end

    # When using submodules, bundler leaves old submodules behind. Over time this inflates
    # the size of the the bundled gems.  So we'll clean it up.
    def clean_old_submodules
      # https://stackoverflow.com/questions/38800129/parsing-a-gemfile-lock-with-bundler
      lockfile = "#{cache_area}/Gemfile.lock"
      return unless File.exist?(lockfile)

      parser = Bundler::LockfileParser.new(Bundler.read_file(lockfile))
      specs = parser.specs

      # specs = Bundler.load.specs
      # IE: spec.source.to_s: "https://github.com/tongueroo/webpacker.git (at jets@a8c4661)"
      submoduled_specs = specs.select do |spec|
        spec.source.to_s =~ /@\w+\)/
      end

      # find git shas to keep
      # IE: ["a8c4661", "abc4661"]
      git_shas = submoduled_specs.map do |spec|
        md = spec.source.to_s.match(/@(\w+)\)/)
        git_sha = md[1]
      end

      # IE: /tmp/jets/demo/cache/bundled/gems/ruby/2.5.0/bundler/gems/webpacker-a8c46614c675
      Dir.glob("#{cache_area}/bundled/gems/ruby/2.5.0/bundler/gems/*").each do |path|
        sha = path.split('-').last[0..6] # only first 7 chars of the git sha
        unless git_shas.include?(sha)
          puts "Removing old submoduled gem: #{path}"
          FileUtils.rm_rf(path) # REMOVE old submodule directory
        end
      end
    end

    def copy_gemfiles
      FileUtils.mkdir_p(cache_area)
      FileUtils.cp("#{@full_project_path}Gemfile", "#{cache_area}/Gemfile")
      FileUtils.cp("#{@full_project_path}Gemfile.lock", "#{cache_area}/Gemfile.lock")
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

    def cache_check_message
      if File.exist?("#{Jets.build_root}/cache")
        puts "The #{Jets.build_root}/cache folder exists. Incrementally re-building the jets using the cache.  To clear the cache: rm -rf #{Jets.build_root}/cache"
      end
    end

    def check_ruby_version
      unless ruby_version_supported?
        puts "You are using ruby version #{RUBY_VERSION} which is not supported by Jets."
        ruby_variant = Jets::RUBY_VERSION.split('.')[0..1].join('.') + '.x'
        abort("Jets uses ruby #{Jets::RUBY_VERSION}.  You should use a variant of ruby #{ruby_variant}".colorize(:red))
      end
    end

    def ruby_version_supported?
      pattern = /(\d+)\.(\d+)\.(\d+)/
      md = RUBY_VERSION.match(pattern)
      ruby = {major: md[1], minor: md[2]}
      md = Jets::RUBY_VERSION.match(pattern)
      jets = {major: md[1], minor: md[2]}

      ruby[:major] == jets[:major] && ruby[:minor] == jets[:minor]
    end

    def cache_area
      "#{Jets.build_root}/cache" # cleaner to use full path for this setting
    end

    # Provide pretty clear way to desinate full path.
    # full("bundled") => /tmp/jets/demo/bundled
    def full(relative_path)
      "#{Jets.build_root}/#{relative_path}"
    end

    # Group all the path settings together here
    def self.tmp_app_root
      Jets::Commands::Build.tmp_app_root
    end

    def tmp_app_root
      self.class.tmp_app_root
    end

    def sh(command)
      puts "=> #{command}".colorize(:green)
      success = system(command)
      abort("#{command} failed to run") unless success
      success
    end

    def headline(message)
      puts "=> #{message}".colorize(:cyan)
    end
  end
end
