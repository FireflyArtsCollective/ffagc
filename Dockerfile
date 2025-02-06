# #####################################################################
# # Stage 1: Install gems and precompile assets.
# #####################################################################
FROM ruby:3.3-slim AS build
WORKDIR /app

# Set a random secret key base so we can precompile assets.
ENV SECRET_KEY_BASE airport_gap_secret_key_base

# Install necessary dependencies to set up Node.js and Yarn repos.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  curl \
  gnupg \
  build-essential \
  libpq-dev \
  libyaml-dev

# Set up Node.js and Yarn package repositories.
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install necessary packages to build gems and assets.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  nodejs \
  yarn

# Install gems into the vendor/bundle directory in the workspace.
COPY Gemfile Gemfile.lock /app/
RUN bundle config set --local path "vendor/bundle" && \
  bundle install --jobs 4 --retry 3

# Install JavaScript dependencies to precompile assets.
# COPY package.json yarn.lock /app/
# RUN yarn install

# Precompile app assets as the final step.
COPY . /app/
RUN bin/rails assets:precompile
RUN chown -R www-data:www-data /app

#####################################################################
# Stage 2: Copy gems and assets from build stage and finalize image.
#####################################################################
FROM ruby:3.3-slim
WORKDIR /app

# Install necessary dependencies required to run the Rails application.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  libpq-dev \
  curl && \
  rm -rf /var/lib/apt/lists/*

# Make sure Bundler knows where we're placing our gems coming from
# the build stage.

RUN bundle config set --local path "vendor/bundle"

# switch user
USER www-data:www-data

# Copy everything from the build stage, including gems and precompiled assets.
COPY --from=build /app /app/

EXPOSE 3000
CMD ["bundle", "exec", "rails", "s", "-p", "3000"]
