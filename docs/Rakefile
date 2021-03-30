# server-side require
require 'opal'
require 'opal-jquery'
require 'opal-browser'

# Note the jekyll-opal plugin loads a minimum baseline of opal that doesnt include extra
# server-side requires. So we'll compile our own version instead.

namespace :opal do
  desc "Build our app to app.js"
  task :build do
    puts "build opal files"
    Opal.append_path "./opal"
    compiled = Opal::Builder.build("app").to_s
    IO.write("js/app.js", compiled)
  end
end

require 'html-proofer'

namespace :html do
  desc "proof read the html links"
  task :proof do
    system "bundle exec jekyll build"
    HTMLProofer.check_directory(
      "./_site",
      # hacks to get html proof to pass links we wanted ignored
      check_html: true,
      # check_favicon: true,
      only_4xx: true,
      allow_hash_href: true,
      empty_alt_ignore: true,
    ).run
  end
end

task :default => ["opal:build", "html:proof"]
