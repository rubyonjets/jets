## Overview

There are 2 things to point out:

1. What the user's environment contains - cannot control this, can only suggest
2. What the lambda environment contains - can fully control this

* User can develop with ruby 2.4 and bundle gems and test and be happy. Hopefully they eventually learn to test with ruby 2.2.0 (when they run into bugs).
* When `lam build` runs it will bundle it in ruby 2.2.0 though.
* When lambda runs it will call `lam` with ruby 2.2.0. The gems will be installed in 2.2.0
	* Hope all works

## Download commands

```sh
# linux 64bit
wget http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz .
mkdir ruby-linux
tar -xvf traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz -C ruby-linux
# mac
wget http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-20150715-2.2.2-osx.tar.gz
mkdir ruby-mac
tar -xvf traveling-ruby-20150715-2.2.2-osx.tar.gz -C ruby-mac

# another version
mkdir hello-1.0.0-linux-x86_64/lib/ruby && tar -xzf packaging/traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz -C hello-1.0.0-linux-x86_64/lib/ruby
```

## Launch Instance for Testing

```sh
aws ec2 run-instances --image-id ami-8c1be5f6 --count 1 --instance-type t2.micro --key-name default --security-groups demo
```

## Tree Structure

```sh
lib/
├── app
│   └── hello.rb
├── ruby
│   ├── bin
│   │   ├── gem
│   │   ├── irb
│   │   ├── rake
│   │   ├── ruby
│   │   └── ruby_environment
│   ├── bin.real
│   │   ├── bundle
│   │   ├── bundler
│   │   ├── gem
│   │   ├── irb
│   │   ├── rake
│   │   └── ruby
│   └── lib
│       └── ruby
│           ├── 2.2.0
...
│           │   └── yaml.rb
│           ├── gems
│           │   └── 2.2.0
│           │       ├── gems
│           │       │   ├── attr_extras-5.2.0
│           │       │   │   ├── attr_extras.gemspec
...
│           │       │   ├── bundler-1.9.9
...
│           │           └── rake-12.2.1.gemspec
...
└── vendor
    ├── Gemfile
    ├── Gemfile.lock
    └── ruby
        └── 2.2.0 <= IMPORTANT: bundler copies gems to folder with running ruby version
            ├── gems
            │   ├── concurrent-ruby-1.0.5
            │   ├── faker-1.7.3
            │   └── i18n-0.9.0
...
```

* [Full tree](https://gist.github.com/tongueroo/c42f9d35b15b06eb810802243f4e2f6d)

