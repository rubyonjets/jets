#!/bin/bash -exu

# https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-debian-8
apt-get update
apt-get install default-jre -y

# to make java 1.8 by default if you keep java-1.7.0.  We dont need to do this:
# update-alternatives --config java #pick java 1.8
# update-alternatives --config javac #pick java 1.8

# to show java_home
java -XshowSettings:properties -version

###
# maven install: https://maven.apache.org/install.html
#
# maven url is down, comment out since we're not using maven
# wget http://mirror.cogentco.com/pub/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz
# tar zxf apache-maven-3.5.3-bin.tar.gz
# mkdir -p /opt
# mv apache-maven-3.5.3 /opt/maven
# ln -s /opt/maven/bin/mvn /usr/local/bin/mvn
