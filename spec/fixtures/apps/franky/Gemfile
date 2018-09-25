source "https://rubygems.org"

if File.exist?("dev.mode")
  gem "jets", path: "#{ENV['HOME']}/environment/jets"
else
  gem "jets", git: "https://github.com/tongueroo/jets.git", submodules: true
end

gem "webpacker", git: "https://github.com/tongueroo/webpacker.git", branch: "jets"
# gem "pg"
gem "pg", '~> 0.21'

# gem "mysql2"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '~> 2.13'
  # gem 'selenium-webdriver'
  gem 'shotgun'
  gem 'rack'
  # gem 'foreman' # foreman locks down to a thor version that doesnt match with jet's thor
end

group :test do
  gem 'rspec'
end
