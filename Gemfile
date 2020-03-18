source "https://rubygems.org"

# Specify your gem dependencies in jets.gemspec
gemspec

# required here for specs
# TODO: Only require webpacker in Gemfile of project if possible.
# Need both because of jets/application.rb and jets/webpacker/middleware_setup.rb
group :development, :test do
  gem "mysql2", "~> 0.5.2"
  gem "dynomite"
  gem "jetpacker"
  gem "rspec_junit_formatter"
end
