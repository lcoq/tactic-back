FROM ruby:2.5.9

ARG LSB_RELEASE_NAME=buster
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $LSB_RELEASE_NAME-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update -qq && apt-get install -y postgresql-client-13

WORKDIR /code
COPY Gemfile /code/Gemfile
COPY Gemfile.lock /code/Gemfile.lock
RUN bundle install
COPY . /code
EXPOSE 3000
CMD rm -f /code/tmp/pids/server.pid && rails server -b 0.0.0.0