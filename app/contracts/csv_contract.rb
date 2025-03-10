require 'dry/validation'

class CsvContract < Dry::Validation::Contract
  EXPECTED_HEADERS = %w[store name description price categories].freeze

  params do
    required(:headers).filled(:array).each(:str?)
  end

  rule(:headers) do
    missing_headers = EXPECTED_HEADERS - value
    extra_headers = value - EXPECTED_HEADERS

    key.failure("Missing headers: #{missing_headers.join(', ')}") if missing_headers.any?
    key.failure("Unexpected headers: #{extra_headers.join(', ')}") if extra_headers.any?
  end
end