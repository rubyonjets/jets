source "https://rubygems.org"

# Specify your gem dependencies in jets.gemspec
gemspec

# required here for specs
group :development, :test do
  gem "mysql2", "~> 0.5.2"
  gem "dynomite", "~> 2.0.0"
end

group :test do
  gem "actionpack", "~> 7.1.3" # jets shim specs
end
