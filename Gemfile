source "https://rubygems.org"

# Specify your gem dependencies in jets.gemspec
gemspec

# required here for specs
# TODO: Would like to only required this in the project's Gemfile
# right now need both because of jets/application.rb and
# jets/webpacker/middleware_setup.rb
group :development, :test do
  gem "webpacker", git: "git@github.com:tongueroo/webpacker.git", branch: "jets"
end
