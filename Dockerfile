# references the ruby image that we want to use, ruby version 2.3.1
FROM ruby:2.3.1
# build essential is required to compile debian package and libpq-dev is for postgres
# node-js is our javascript runtime
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
# set environmental variable
ENV RAILS_ROOT /rails_app
# create tmp/pids directory in rails app root folder
RUN mkdir -p $RAILS_ROOT/tmp/pids
# set working directory to rails root
WORKDIR $RAILS_ROOT
# copy over startup.sh file
COPY config/startup.sh /opt/startup.sh
# copy over Gemfile
COPY Gemfile Gemfile
# copy over Gemfile.lock
COPY Gemfile.lock Gemfile.lock
# install bundler gem
RUN gem install bundler
# run bundle install before copying over the entire app. This way installed gems are
# cached and you only have to wait for bundle install to run again if Gemfile is changed
RUN bundle install
# copy over rails files to $RAILS_ROOT
COPY . .