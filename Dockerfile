# Start with base ruby image
FROM ruby:2.7.2

# Install system dependencies
RUN apt-get update -qq || true
RUN apt-get install -y apt-transport-https software-properties-common postgresql-client

# Install app & dependencies
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install -j 4

ADD . /app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the process.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
