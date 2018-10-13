class Jets::Builders
  class RubyPackager
    include Util

    attr_reader :full_app_root
    def initialize(tmp_app_root)
      @full_app_root = full(tmp_app_root)
    end

    def gemfile_exist?
      gemfile_path = "#{@full_app_root}/Gemfile"
      puts "gemfile_path #{gemfile_path}"
      File.exist?(gemfile_path)
    end

    def install
      return unless gemfile_exist?

      reconfigure_ruby_version
      clean_old_submodules
      bundle_install
      setup_bundle_config
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
      return if poly_only?

      full_project_path = @full_app_root
      headline "Bundling: running bundle install in cache area: #{cache_area}."

      copy_gemfiles(full_project_path)

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

    def finish
      copy_bundled_cache
      extract_ruby
      extract_gems
      tidy
    end

    # Clean up extra unneeded files to reduce package size
    # Because we're removing files (something dangerous) use full paths.
    def tidy
      puts "Tidying project: removing ignored files to reduce package size."
      tidy_project(@full_app_root)
      # The rack sub project has it's own gitignore.
      tidy_project(@full_app_root+"/rack")
    end

    def tidy_project(path)
      Tidy.new(path).cleanup!
    end

    # This is in case the user has a 2.5.x variant.
    # Force usage of ruby version that jets supports
    # The lambda server only has ruby 2.5.0 installed.
    def reconfigure_ruby_version
      ruby_version = "#{@full_app_root}/.ruby-version"
      IO.write(ruby_version, Jets::RUBY_VERSION)
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
        md[1] # git_sha
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

    def copy_gemfiles(full_project_path)
      FileUtils.mkdir_p(cache_area)
      FileUtils.cp("#{full_project_path}/Gemfile", "#{cache_area}/Gemfile")
      FileUtils.cp("#{full_project_path}/Gemfile.lock", "#{cache_area}/Gemfile.lock")
    end

    def setup_bundle_config
      puts "setup_bundle_config".colorize(:cyan)
      puts "cache_area #{cache_area}".colorize(:cyan)
      puts "@full_app_root #{@full_app_root}".colorize(:cyan)
      ensure_build_cache_bundle_config_exists!

      # Override project's .bundle/config and ensure that .bundle/config matches
      # at these 2 spots:
      #   app_root/.bundle/config
      #   bundled/gems/.bundle/config
      cache_bundle_config = "#{cache_area}/.bundle/config"
      app_bundle_config = "#{@full_app_root}/.bundle/config"
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

    def lambdagem_options
      {
        s3: "lambdagems",
        build_root: cache_area, # used in lambdagem
        project_root: @full_app_root, # used in gem_replacer and lambdagem
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

    def copy_bundled_cache
      app_root_bundled = "#{@full_app_root}/bundled"
      if File.exist?(app_root_bundled)
        puts "Removing current bundled from project"
        FileUtils.rm_rf(app_root_bundled)
      end
      # Leave #{Jets.build_root}/bundled behind to act as cache
      FileUtils.cp_r("#{cache_area}/bundled", app_root_bundled)
    end

  private
    def cache_area
      "#{Jets.build_root}/cache" # cleaner to use full path for this setting
    end
  end
end
