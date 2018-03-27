FROM ruby:2.5.0
MAINTAINER areiff@weedmaps.com

ENV DOCKERIZE_VERSION v0.2.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Install entrypoint
COPY ./docker/app/start.sh /start.sh
RUN chmod +x /start.sh

RUN gem install bundler --no-document

# Setup working directory
RUN mkdir /app
WORKDIR /app

# Install bundle (before loading all code)
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

# Install the app. Done last to maximize docker caching
COPY . /app

ENTRYPOINT ["/start.sh"]
