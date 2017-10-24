guard "bundler", cmd: "bundle" do
  watch("Gemfile")
  watch(/^.+\.gemspec/)
end

guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  puts "ruby.lib_files #{ruby.lib_files.inspect}"
  dsl.watch_spec_files_for(ruby.lib_files)

  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
end
