# Use a smaller Ruby base image for better performance
FROM ruby:3.2.2-slim

# Set environment variables
ENV LANG=C.UTF-8 \
    APP_PATH=/app

# Install dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    postgresql-client \
    git \
    vim \
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
CMD ["bundle", "exec", "puma"]
