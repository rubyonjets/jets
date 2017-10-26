# start off at project root

mkdir -p /tmp/lam_build
cp Gemfile* /tmp/lam_build/
cd /tmp/lam_build # cd into there to build TravelingRuby

wget http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz .
mkdir -p bundled/ruby # tmp/lam_build/bundled/ruby
tar -xvf traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz -C bundled/ruby
# ls ruby => bin  bin.real  info  lib
# bundled/ruby/bin/ruby -v # works now :)

# had to modify Gemfile and update the local path for linux
bundle install --path bundled/gems

# DONT THINK THAT I NEED TO COPY THE Gemfile into bundled/gems...
# mv Gemfile* bundled/gems/ # copy Gemfile from the project to bundled/gems
# IMPORTANT: the Gemfile must be in the same bundled/gems folder

# now we have both bundled/gems bundled/ruby :)
bundled/gems/ruby/2.2.0/bin/print_ruby_info # should work


# Let's move back to the project and test the wrapper, it should work also
mv bundled ~/lam-test/lam/spec/fixtures/project/
cd ~/lam-test/lam/spec/fixtures/project # back to project root
