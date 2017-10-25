# linux 64bit
wget http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz .
mkdir ruby-linux
tar -xvf traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz -C ruby-linux

# mac
wget http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-20150715-2.2.2-osx.tar.gz
mkdir ruby-mac
tar -xvf traveling-ruby-20150715-2.2.2-osx.tar.gz -C ruby-mac


aws ec2 run-instances --image-id ami-8c1be5f6 --count 1 --instance-type t2.micro --key-name default --security-groups demo

