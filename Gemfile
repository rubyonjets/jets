source "https://rubygems.org"

# Specify your gem dependencies in jets.gemspec
gemspec

# required here for specs
# TODO: Would like to only required this in the project's Gemfile
# right now need both because of jets/application.rb and
# jets/webpacker/middleware_setup.rb
group :development, :test do
  gem "webpacker", git: "https://github.com/tongueroo/webpacker.git", branch: "jets"
  gem "rspec_junit_formatter"
  # there are development dependencies because we want to lazy load them
  # in the app. but we want to have them so we can run specs.
  gem "pg", "~> 0.21"
end
