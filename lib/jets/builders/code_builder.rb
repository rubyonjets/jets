require "action_view"
require "fileutils"
require "net/http"
require "open-uri"
require "socket"

# Some important folders to help understand how jets builds a project:
#
# /tmp/jets: build root where different jets projects get built.
# /tmp/jets/project: each jets project gets built in a different subdirectory.
#
# The rest of the folders are subfolders under /tmp/jets/project.
#
module Jets::Builders
  class CodeBuilder
    include Jets::AwsServices
    include Util
    extend Memoist

    attr_reader :full_project_path
    def initialize
      # Expanding to the full path and capture now.
      # Dir.chdir gets called later and we'll lose this info.
      @full_project_path = File.expand_path(Jets.root) + "/"
      @version_purger = Purger.new
    end

    def build
      @version_purger.purge
      cache_check_message

      clean_start
      assets_precompile
      run_webpack # easier to do before we copy the project because node and yarn has been likely setup in the that dir
      copy_project
      copy_ruby_version_file
      Dir.chdir("#{stage_area}/code") do
        # These commands run from project root
        code_setup
        package_ruby
        code_finish
      end
    end

    # Resolves the chicken-and-egg problem with md5 checksums. The handlers need
    # to reference files with the md5 checksum.  The files are the:
    #
    #   jets/code/rack-checksum.zip
    #   jets/code/opt-checksum.zip
    #
    # We compute the checksums before we generate the node shim handlers.
    def calculate_md5s
      Md5.compute! # populates Md5.checksums hash
    end

    def generate_shims
      headline "Generating shims in the handlers folder."
      # Crucial that the Dir.pwd is in the tmp_code because for
      # Jets::Builders::app_files because Jets.boot set ups
      # autoload_paths and this is how project classes are loaded.
      Jets::Builders::HandlerGenerator.build!
    end

    def create_zip_files
      folders = Md5.stage_folders
      # Md5.stage_folders ["stage/bundled", "stage/code"]
      folders.each do |folder|
        zip = Md5Zip.new(folder)
        if exist_on_s3?(zip.md5_name)
          puts "Already exists: s3://#{s3_bucket}/jets/code/#{zip.md5_name}"
        else
          zip = Md5Zip.new(folder)
          zip.create
        end
      end
    end

    def exist_on_s3?(filename)
      return false if ENV['JETS_BUILD_NO_INTERNET']
      s3_key = "jets/code/#{filename}"
      begin
        Jets.logger.debug "Checking s3://#{s3_bucket}/#{s3_key}"
        s3.head_object(bucket: s3_bucket, key: s3_key)
        true
      rescue Aws::S3::Errors::NotFound, Aws::S3::Errors::Forbidden
        false
      end
    end

    def code_setup
      reconfigure_development_webpacker
    end

    def code_finish
      # Reconfigure code
      store_s3_base_url
      disable_webpacker_middleware

      # Code prep and zipping
      check_code_size!
      calculate_md5s # must be called before create_zip_files and generate_shims because checksums need to be populated
      # generate_shims and create_zip_files use checksums
      #
      # Notes:
      #
      # Had moved calculate_md5s to fix a what thought was a subtle issue https://github.com/tongueroo/jets/pull/424
      # But am unsure about that the fix now. This essentially reverts that issue.
      #
      # Fix in https://github.com/tongueroo/jets/pull/459
      #
      generate_shims # the generated handlers/data.yml has rack_zip key
      create_zip_files
    end

    def check_code_size!
      CodeSize.check!
    end

    # Thanks https://stackoverflow.com/questions/9354595/recursively-getting-the-size-of-a-directory
    # Seems to overestimate a little bit but close enough.
    def dir_size(folder)
      Dir.glob(File.join(folder, '**', '*'))
        .select { |f| File.file?(f) }
        .map{ |f| File.size(f) }
        .inject(:+)
    end

    # Store s3 base url is needed for asset serving from s3 later. Need to package this
    # as part of the code so we have a reference to it.
    # At this point the minimal stack exists, so we can grab it with the AWS API.
    # We do not want to grab this as part of the live request because it is slow.
    def store_s3_base_url
      return if Jets.config.mode == "job"
      write_s3_base_url("#{stage_area}/code/config/s3_base_url.txt")
    end

    def write_s3_base_url(full_path)
      FileUtils.mkdir_p(File.dirname(full_path))
      IO.write(full_path, s3_base_url)
    end

    def s3_base_url
      # Allow user to set assets.base_url
      #
      #   Jets.application.configure do
      #     config.assets.base_url = "https://cloudfront.com/my/base/path"
      #   end
      #
      return Jets.config.assets.base_url if Jets.config.assets.base_url

      # Note: subdomain form works with CORs but the subfolder form does not. Using subfolder form.
      region = Jets.aws.region
      asset_base_url = region == 'us-east-1' ?
        "https://#{s3_bucket}.s3.amazonaws.com/jets" :
        "https://#{s3_bucket}.s3-#{region}.amazonaws.com/jets"
    end

    def s3_bucket
      Jets.aws.s3_bucket
    end

    def disable_webpacker_middleware
      full_path = "#{"#{stage_area}/code"}/config/disable-webpacker-middleware.txt"
      FileUtils.mkdir_p(File.dirname(full_path))
      FileUtils.touch(full_path)
    end

    def assets_precompile
      return if skip_assets?
      return unless gemfile_include?("sprockets-jets")
      sh "jets assets:precompile"
    end

    # This happens in the current app directory not the tmp code for simplicity.
    # This is because the node and yarn has likely been set up correctly there.
    def run_webpack
      return if skip_assets?
      return unless gemfile_include?("jetpacker")

      headline "Compling assets in current project directory"
      sh("yarn install")

      ENV['WEBPACKER_ASSET_HOST'] = asset_host if Jets.config.assets.base_url
      webpack_command = File.exist?("#{Jets.root}/bin/webpack") ?
          "bin/webpack" :
          `which webpack`.strip
      sh "JETS_ENV=#{Jets.env} #{webpack_command}"
    end

    def skip_assets?
      if ENV['JETS_SKIP_ASSETS']
        puts "Skip compiling assets".color(:yellow) # useful for debugging
        return true
      end
      return true if Jets.config.mode == "job"
      return true unless Jets.config.respond_to?(:assets)
      Jets.config.assets.enable_webpack
    end

    # Different url for these. Examples:
    #
    #   asset_host  https://demo-dev-s3bucket-lw5vq7ht8ip4.s3.us-west-2.amazonaws.com/jets/public/packs/media/images/boltops-0dd1c6bd.png
    #   s3_base_url https://s3-us-west-2.amazonaws.com/demo-dev-s3bucket-lw5vq7ht8ip4/jets/packs/media/images/boltops-0dd1c6bd.png
    #
    # Interesting: asset_host works but s3_base_url does not for CORs. IE: reactjs or vuejs requests
    # Thinking AWS configures the non-subdomain url endpoint to be more restrictive.
    #
    # Allow user to set assets.asset_host
    #
    #   Jets.application.configure do
    #     config.assets.asset_host = "https://cloudfront.com/my/base/path"
    #   end
    #
    def asset_host
      assets = Jets.config.assets
      return assets.base_url if assets.base_url && assets.base_url != "s3_endpoint"

      # By default, will use the s3 url endpoint directly by convention
      region = Jets.aws.region
      asset_base_url = region == 'us-east-1' ?
        "https://#{s3_bucket}.s3.amazonaws.com" :
        "https://#{s3_bucket}.s3.#{region}.amazonaws.com"

      "#{asset_base_url}/jets/public" # s3_base_url
    end

    def gemfile_include?(name)
      # Old code, leaving around for now:
      # Thanks: https://stackoverflow.com/questions/4195735/get-list-of-gems-being-used-by-a-bundler-project
      # webpacker_loaded = Gem.loaded_specs.keys.include?("webpacker")
      # return unless webpacker_loaded

      # Checking this way because when using jets standalone for Afterburner mode we don't want to run into
      # bundler gem collisions.  TODO: figure out the a better way to handle the collisions.
      lines = IO.readlines("#{Jets.root}/Gemfile")
      lines.detect { |l| l =~ /#{name}/ }
    end

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
      headline "Copying current project directory to temporary build area: #{"#{stage_area}/code"}"
      FileUtils.rm_rf("#{build_area}/stage") # clear out from previous build's stage area
      FileUtils.mkdir_p("#{build_area}/stage")
      FileUtils.rm_rf("#{stage_area}/code") # remove current code folder
      move_node_modules(Jets.root, Jets.build_root)
      begin
        Jets::Util.cp_r(@full_project_path, "#{stage_area}/code")
      ensure
        move_node_modules(Jets.build_root, Jets.root) # move node_modules directory back
      end
    end

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

    # Bit hacky but this saves the user from accidentally forgetting to change this
    # when they deploy a jets project in development mode
    def reconfigure_development_webpacker
      return unless Jets.env.development?
      headline "Reconfiguring webpacker development settings for AWS Lambda."

      webpacker_yml = "#{"#{stage_area}/code"}/config/webpacker.yml"
      return unless File.exist?(webpacker_yml)

      config = Jets::Util::Yamler.load_file(webpacker_yml)
      config["development"]["compile"] = false # force this to be false for deployment
      new_yaml = YAML.dump(config)
      IO.write(webpacker_yml, new_yaml)
    end

    def ruby_packager
      RubyPackager.new(tmp_code)
    end
    memoize :ruby_packager

    def rack_packager
      RackPackager.new("#{tmp_code}/rack")
    end
    memoize :rack_packager

    def package_ruby
      if ENV['JETS_SKIP_PACKAGE']
        puts "Skip packaging ruby".color(:yellow) # useful for developing handlers
        return
      end
      return if Jets.poly_only?

      check_agree
      ruby_packager.install
      rack_packager.install
      ruby_packager.finish # by this time we have a /tmp/jets/demo/stage/code/vendor/gems
      rack_packager.finish

      build_lambda_layer
    end

    def check_agree
      agree = Jets::Api::Agree.new
      agree.prompt
    end

    def build_lambda_layer
      return if Jets.poly_only?
      lambda_layer = LambdaLayer.new
      lambda_layer.build
    end

    def cache_check_message
      if File.exist?("#{Jets.build_root}/cache")
        puts "The #{Jets.build_root}/cache folder exists. Incrementally re-building the jets using the cache.  To clear the cache: rm -rf #{Jets.build_root}/cache"
      end
    end

    def copy_ruby_version_file
      ruby_version_path = Jets.root.join(".ruby-version")
      return unless File.exists?(ruby_version_path)
      FileUtils.cp_r(ruby_version_path, build_area)
    end

    # Group all the path settings together here
    def self.tmp_code
      Jets::Cfn::Builder.tmp_code
    end

    def tmp_code
      self.class.tmp_code
    end
  end
end
