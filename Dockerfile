FROM ruby:3.0.3

RUN apt-get update -qq && apt-get install -y postgresql-client

WORKDIR /code
COPY Gemfile /code/Gemfile
COPY Gemfile.lock /code/Gemfile.lock
RUN bundle install
EXPOSE 3000
CMD rm -f /code/tmp/pids/server.pid && rails server -b 0.0.0.0