FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y postgresql-client
WORKDIR /code
COPY Gemfile /code/Gemfile
COPY Gemfile.lock /code/Gemfile.lock
RUN bundle install
COPY . /code
EXPOSE 3000
CMD rm -f /code/tmp/pids/server.pid && rails server -b 0.0.0.0