mkdir -p tmp/build
cd tmp/build # cd into there to build project

wget http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz .
mkdir ruby
tar -xvf traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz -C ruby
# ls ruby => bin  bin.real  info  lib

mkdir bundled
mv ruby bundled

# bundled/ruby/bin/ruby -v # works now :)

# had to modify Gemfile and update the local path for linux
bundle install --path gems
mv gems bundled/
cp ../../Gemfile* bundled/gems/ # copy Gemfile from the project to bundled/gems
# IMPORTANT: the Gemfile must be in the same bundled/gems folder

# now we have both bundled/gems bundled/ruby :)


cd ../.. # back to project root

bundled/gems/ruby/2.2.0/bin/print_ruby_info # should work
# wrapper should also work

