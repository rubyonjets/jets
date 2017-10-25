### Packaging Gems Info

### Structure

This is the structure that TravelingRuby uses in it's tutorial.

```sh
PROJECT/YOUR_BINARY_WRAPPER (hello)
PROJECT/lib/ruby/bin/ruby -> PROJECT/lib/ruby/bin.real/ruby
PROJECT/lib/vendor/ruby/2.2.0/bin/print_ruby_info # the gem binaries are here
```

* Instead calling the ruby binary `lam process` command directly.
* Lam will require 'bundler/setup' so the user's gems will be required properly
* Skip the overhead of having another wrapper

```sh
PROJECT/vendor/ruby/2.2.0/bin/lam # the gem binaries are here
```

### Packaging Gems Commands

```
mkdir packaging/tmp
cp Gemfile Gemfile.lock packaging/tmp/ # this are from the user's project
cd packaging/tmp

# here's where the gems are instaleld into packaging/vendor/
BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development
# IMPORTANT: Think I'll make the user switch to 2.2.0 and error the build proccess.

##############
I can call ruby bin files directly.
I was WRONG. Cannot call gem bin files directly because I need to make sure that
bundler/setup gets loaded before calling the gem bin.
Tried moving bundler/setup into the lam library itself but get all sorts of warnings.

hello-1.0.0-linux-x86_64/lib/vendor/ruby/2.2.0/bin/lam help
BUT the shabang line has: #!/usr/bin/env ruby2.0 .. but only on linux..
Simply cannot rename the darn ruby version folder.
#############


cd ../..
rm -rf packaging/tmp # remove working space

# reduce the zip package size!
rm -f packaging/vendor/*/*/cache/*
```

Now we can copy over the generated vendored files

##################################
# clean
rm -rf packaging/vendor/

bundle update
rake package:linux:x86_64 DIR_ONLY=1

mkdir packaging/tmp
cp Gemfile Gemfile.lock packaging/tmp/
cd packaging/tmp
BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development
cd ../..

cp -pR packaging/vendor hello-1.0.0-linux-x86_64/lib/
cp Gemfile Gemfile.lock hello-1.0.0-linux-x86_64/lib/vendor/
mkdir hello-1.0.0-linux-x86_64/lib/vendor/.bundle
cp packaging/bundler-config hello-1.0.0-linux-x86_64/lib/vendor/.bundle/config

find . -name print_ruby_info


# Wrapper script `lam`

```bash
#!/bin/bash
set -e

# Figure out where this script is located.
SELFDIR="`dirname \"$0\"`"
SELFDIR="`cd \"$SELFDIR\" && pwd`"

# Tell Bundler where the Gemfile and gems are.
export BUNDLE_GEMFILE="$SELFDIR/lib/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG

# Run the actual app using the bundled Ruby interpreter, with Bundler activated.
exec "$SELFDIR/lib/ruby/bin/ruby" -rbundler/setup "$SELFDIR/lib/app/hello.rb"
```


### Building Ruby
http://cache.ruby-lang.org/pub/ruby/2.2/

```sh
wget http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz
tar xvfvz ruby-2.2.2.tar.gz
cd ruby-2.2.2
./configure
make
sudo make install
```
