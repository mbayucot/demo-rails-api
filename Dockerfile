# Use a smaller Ruby base image for better performance
FROM ruby:3.2.2-slim

# Set environment variables
ENV LANG=C.UTF-8 \
    APP_PATH=/app

# Install dependencies
RUN apt-get update && apt-get install -y --fix-missing \
  build-essential \
  curl \
  gcc \
  git \
  libcurl4-openssl-dev \
  libpq-dev \
  libxml2-dev \
  ssh \
  supervisor \
  vim \
  postgresql-client  \
    && rm -rf /var/lib/apt/lists/*  # Clean up APT cache to reduce image size

# Set working directory
WORKDIR $APP_PATH

# Copy only the files necessary for installing gems
COPY .ruby-version Gemfile ./

# Install Bundler and Gems with caching
RUN gem install bundler && bundle install --jobs 4 --retry 3

# Copy the rest of the application
COPY . .

# Expose only the HTTPS port
EXPOSE 3000

# Start the Rails server with Puma
COPY .devops/conf/supervisor/conf.d/ /etc/supervisor/conf.d
CMD /usr/bin/supervisord -n