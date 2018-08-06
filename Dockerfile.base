FROM ruby:2.5.1
MAINTAINER Tung Nguyen <tongueroo@gmail.com>

RUN apt-get update && \
  apt-get install -y net-tools netcat && \
  rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get purge

# Packages
# capybara-webkit: libqt4-dev libqtwebkit-dev
RUN apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository ppa:git-core/ppa -y && \
  apt-get update && \
  apt-get install -y \
    build-essential \
    libqt4-dev libqtwebkit-dev \
    nodejs \
    telnet \
    curl \
    vim \
    htop \
    mysql-client \
    lsof && \
  rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get purge

# ssh key for bundle to access gems that are in private repos
# COPY config/ssh /root/.ssh
# RUN chmod 600 /root/.ssh/id_rsa-boltops-docker

# Install bundle of gems
RUN gem install bundler
WORKDIR /tmp
COPY lib/jets/version.rb /tmp/lib/jets/version.rb
COPY jets.gemspec /tmp/
COPY Gemfile* /tmp/
RUN bundle install --jobs=4 --retry=3 && rm -rf /root/.bundle/cache

# Do not try to precompile assets here because it could resurrect files
# This happened with config/initializers/rollbar.rb.

# Add development like customizations
# COPY config/home/irbrc /root/.irbrc
ENV TERM xterm

COPY .codebuild/scripts /tmp/scripts
RUN bash -eux /tmp/scripts/install-docker.sh
RUN bash -exu /tmp/scripts/install-java.sh
RUN bash -exu /tmp/scripts/install-dynamodb-local.sh
RUN bash -exu /tmp/scripts/install-node.sh

RUN apt-get install -y zip

CMD ["/bin/bash"]
