require 'open-uri'
require 'json'
require 'bigdecimal'

# Fetches the current exchange rate between two currencies using the free
# Frankfurter API (https://www.frankfurter.app), which requires no API key
# and is backed by European Central Bank reference rates.
class ExchangeRateFetcherService
  API_URL = "https://api.frankfurter.app/latest".freeze

  def call(from = "USD", to = "CZK")
    return BigDecimal(1) if from == to

    body = fetch("#{API_URL}?from=#{from}&to=#{to}")
    rate = JSON.parse(body).dig("rates", to)
    raise "No exchange rate returned for #{from} -> #{to}" if rate.nil?

    BigDecimal(rate.to_s)
  end

  private

  def fetch(url)
    URI.open(url) { |f| f.read }
  end
end
