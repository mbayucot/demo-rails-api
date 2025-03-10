require 'dry/validation'

class ProductRowValidator
  Schema = Dry::Schema.Params do
    required(:name).filled(:string, min_size?: 3, max_size?: 100)
    required(:description).filled(:string, min_size?: 10)
    required(:price).filled(:float, gt?: 0)
    required(:store).filled(:string) # Store name
    optional(:categories).maybe(:string) # Comma-separated categories
  end

  def self.call(row)
    result = Schema.call(row)
    result.success? ? { success: true, data: row } : { success: false, error: result.errors.to_h }
  end
end