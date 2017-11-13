source "https://rubygems.org"

if ENV['LOCAL_JETS_GEM']
  gem "jets", path: "#{ENV['HOME']}/src/tongueroo/jets"
else
  gem "jets", git: "git@github.com:tongueroo/jets.git", submodules: true
end
# gem "print_ruby_info"

# locking down for TravelingRuby for now
gem "nokogiri", "1.6.5"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '~> 2.13'
  # gem 'selenium-webdriver'
  gem 'rspec'
  gem 'shotgun'
  gem 'rack'
  # gem 'foreman' # foreman locks down to a thor version that doesnt match with jet's thor
end
