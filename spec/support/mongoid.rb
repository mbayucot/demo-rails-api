RSpec.configure do |config|
  require 'mongoid-rspec'

  # Include Mongoid matchers for model testing
  config.include Mongoid::Matchers, type: :model

  # Ensure Mongoid transactions don't interfere with tests
  config.before(:suite) do
    Mongoid.load!("#{Rails.root}/config/mongoid.yml", :test)
  end

  # Clean MongoDB before each test (to avoid data conflicts)
  config.before(:each) do
    Mongoid.purge!
  end
end