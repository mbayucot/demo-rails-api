require 'dry/validation'

class CsvValidator
  Schema = Dry::Schema.Params do
    required(:headers).filled(:array).each(:str?)
  end

  EXPECTED_HEADERS = %w[store name description price categories].freeze

  def self.call(headers)
    result = Schema.call(headers: headers)

    return { success: false, error: result.errors.to_h } if result.failure?

    missing_headers = EXPECTED_HEADERS - headers
    extra_headers = headers - EXPECTED_HEADERS

    if missing_headers.any?
      return { success: false, error: "Missing headers: #{missing_headers.join(', ')}" }
    elsif extra_headers.any?
      return { success: false, error: "Unexpected headers: #{extra_headers.join(', ')}" }
    end

    { success: true }
  end
end