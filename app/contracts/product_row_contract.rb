require 'dry/validation'

class ProductRowContract < Dry::Validation::Contract
  params do
    required(:name).filled(:string, min_size?: 3, max_size?: 100)
    required(:description).filled(:string, min_size?: 10)
    required(:price).filled(:float, gt?: 0)
    required(:store).filled(:string) # Store name (will be validated separately)
    optional(:categories).maybe(:string) # Comma-separated category names
  end

  rule(:categories) do
    unless value.nil? || value.split(',').all? { |c| c.strip.match?(/\A[a-zA-Z0-9\s\-]+\z/) }
      key.failure("must be a comma-separated list of valid category names")
    end
  end
end