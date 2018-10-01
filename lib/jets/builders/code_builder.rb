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
    include Jets::AwsServices
    include Util

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
        package_ruby
        finish_app_root_setup
        create_zip_file
      end
    end
    time :build

    def start_app_root_setup
      tidy_project
      reconfigure_development_webpacker
      generate_node_shims
    end
    time :start_app_root_setup

    def finish_app_root_setup
      return if poly_only?

      store_s3_base_url
    end
    time :finish_app_root_setup

    # Store s3 base url is needed for asset serving from s3 later. Need to package this
    # as part of the code so we have a reference to it.
    # At this point the minimal stack exists, so we can grab it with the AWS API.
    # We do not want to grab this as part of the live request because it is slow.
    def store_s3_base_url
      IO.write("#{full(tmp_app_root)}/config/s3_base_url.txt", s3_base_url)
    end

    def s3_base_url
      # Allow user to set assets.base_url
      #
      #   Jets.application.configure do
      #     config.assets.base_url = "https://cloudfront.com/my/base/path"
      #   end
      #
      return Jets.config.assets.base_url if Jets.config.assets.base_url

      resp = cfn.describe_stacks(stack_name: Jets::Naming.parent_stack_name)
      stack = resp.stacks.first
      output = stack["outputs"].find { |o| o["output_key"] == "S3Bucket" }
      bucket_name = output["output_value"] # s3_bucket
      region = Jets.aws.region

      asset_base_url = "https://s3-#{region}.amazonaws.com"
      "#{asset_base_url}/#{bucket_name}/jets/public" # s3_base_url
    end

    # This happens in the current app directory not the tmp app_root for simplicity
    def compile_assets
      puts "TEMPORARY TURN OFF COMPILE ASSETS"
      return
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

    def package_ruby
      packager = RubyPackager.new(tmp_app_root)
      packager.reconfigure_ruby_version
      packager.clean_old_submodules
      packager.bundle_install(full_project_path)
      rack_project = "#{full_project_path}rack/"
      packager.bundle_install(rack_project) if File.exist?(rack_project + "Gemfile")
      packager.copy_bundled_cache
      packager.setup_bundle_config
      packager.extract_ruby
      packager.extract_gems
    end
    time :package_ruby

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

    # Group all the path settings together here
    def self.tmp_app_root
      Jets::Commands::Build.tmp_app_root
    end

    def tmp_app_root
      self.class.tmp_app_root
    end
  end
end
