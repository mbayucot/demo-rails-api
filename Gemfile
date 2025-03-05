source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.0"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

# 📌 Protects against abuse via rate limiting, IP blocking, and throttling
gem 'rack-attack', '~> 6.7'

# 📌 Multi-tenancy support using schema-based separation
gem 'ros-apartment', '~> 3.2'

# 📌 Background job processing with Redis for scalability
gem 'sidekiq', '~> 7.3', '>= 7.3.9'

# 📌 Fast and lightweight JSON serialization alternative to AMS
gem 'blueprinter', '~> 1.1', '>= 1.1.2'

# 📌 Functional programming approach for structuring business logic
gem 'dry-transaction', '~> 0.16.0'

# 📌 Schema-based data validation for predictable application behavior
gem 'dry-validation', '~> 1.11', '>= 1.11.1'

# 📌 Feature flagging and gradual rollouts for controlled deployments
gem 'flipper', '~> 1.3', '>= 1.3.3'

# 📌 Official MongoDB ODM for handling NoSQL data in Rails
gem 'mongoid', '~> 9.0', '>= 9.0.6'

# 📌 Lightweight authorization with policy-based access control
gem 'pundit', '~> 2.4'

# 📌 Flexible authentication solution for Rails applications
gem 'devise', '~> 4.9', '>= 4.9.4'

# 📌 Simple and efficient pagination for ActiveRecord collections
gem 'will_paginate', '~> 4.0', '>= 4.0.1'

# 📌 Handles incoming Stripe webhook events seamlessly
gem 'stripe_event', '~> 2.11'

# 📌 Structured logging to improve debugging and monitoring
#gem 'lograge', '~> 0.14.0'

# 📌 Finite state machine library for managing object states
gem 'aasm', '~> 5.5'

# 📌 Adds JWT authentication support to Devise for APIs
gem 'devise-jwt', '~> 0.12.1'

# 📌 Tracks changes to ActiveRecord models for auditing/versioning
gem 'paper_trail', '~> 16.0'

# 📌 Implements soft delete functionality without physically deleting records
gem 'discard', '~> 1.4'

# 📌 Full-text search capabilities using PostgreSQL
gem 'pg_search', '~> 2.3', '>= 2.3.7'

gem 'retryable'

# 📌 Prevents unsafe database migrations in production
gem 'strong_migrations', '~> 2.2'

gem 'concurrent-ruby', '1.3.4'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rspec-json_expectations'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers'
  gem 'shoulda-callback-matchers'
  gem 'simplecov', require: false
  gem 'fuubar'
  gem 'stripe-ruby-mock'
end

