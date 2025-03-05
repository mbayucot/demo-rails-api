class ProductImportContract < Dry::Validation::Contract
  schema do
    required(:name).filled(:string)
    required(:description).filled(:string)
    required(:price).filled(:float, gt?: 0)
    required(:category).filled(:string)
    required(:store_id).filled(:integer)
    required(:start_at).filled(:string)
    required(:end_at).filled(:string)
  end

  rule(:category) do
    key.failure("Category does not exist") unless Category.exists?(name: value)
  end

  rule(:name, :store_id) do
    if Product.exists?(name: values[:name], store_id: values[:store_id])
      key(:name).failure("Product with this name already exists in the store")
    end
  end

  rule(:start_at, :end_at) do
    begin
      start_time = DateTime.parse(values[:start_at])
      end_time = DateTime.parse(values[:end_at])

      key(:start_at).failure("must be before end_at") if start_time >= end_time
    rescue ArgumentError
      key(:start_at).failure("must be a valid datetime") unless values[:start_at].match?(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
      key(:end_at).failure("must be a valid datetime") unless values[:end_at].match?(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
    end
  end
end