source "https://rubygems.org"

gem "jets", git: "git@github.com:tongueroo/jets.git", submodules: true
# Include webpacker if you are you are building html pages
gem "webpacker", git: "git@github.com:tongueroo/webpacker.git"
# Include pg gem if you are using ActiveRecord
gem "pg"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'shotgun'
  gem 'rack'
end

group :test do
  gem 'rspec'
end
