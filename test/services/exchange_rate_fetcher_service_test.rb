require "test_helper"
require "minitest/mock"

class ExchangeRateFetcherServiceTest < ActiveSupport::TestCase
  SAMPLE_BODY = '{"amount":1.0,"base":"USD","date":"2026-07-17","rates":{"CZK":21.167}}'.freeze

  test "parses the rate for the requested currency pair" do
    service = ExchangeRateFetcherService.new

    service.stub(:fetch, SAMPLE_BODY) do
      assert_equal BigDecimal("21.167"), service.call("USD", "CZK")
    end
  end

  test "returns 1 when converting a currency to itself without calling the API" do
    service = ExchangeRateFetcherService.new

    # The stub raises if fetch is called, proving the API is not hit.
    service.stub(:fetch, ->(*) { raise "fetch should not be called" }) do
      assert_equal BigDecimal(1), service.call("USD", "USD")
    end
  end

  test "raises when the response has no rate for the target currency" do
    service = ExchangeRateFetcherService.new
    body = '{"amount":1.0,"base":"USD","date":"2026-07-17","rates":{}}'

    service.stub(:fetch, body) do
      assert_raises(RuntimeError) { service.call("USD", "CZK") }
    end
  end
end
