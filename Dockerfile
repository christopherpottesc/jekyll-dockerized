FROM ruby:2.6.3 AS jekyll

ENV APP /usr/src/app

# Create app directory
RUN mkdir -p $APP
WORKDIR $APP

# Install app dependencies
ENV BUNDLER_VERSION='2.2.7'
RUN gem install bundler --no-document -v $BUNDLER_VERSION

ENV BUNDLE_PATH /usr/src/bundle
COPY Gemfile* $APP/
RUN bundle config set --local path $BUNDLE_PATH
RUN bundle install --jobs $(nproc)
RUN bundle update --bundler $BUNDLER_VERSION

# Build the app
COPY . $APP
ARG JEKYLL_ENV
ENV JEKYLL_ENV=${JEKYLL_ENV:-production}
RUN bundle exec jekyll build

FROM nginx:1.21.4 AS nginx

ENV BASEURL=/site

# Copy the built app into nginx
COPY --from=jekyll /usr/src/app/_site/ /usr/share/nginx/html$BASEURL
