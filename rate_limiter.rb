require "minitest/autorun"
require "bundler/setup"

class RateLimiterTest < Minitest::Test
  def setup
    @limiter = RateLimiter.new(10)
  end

  def test_limit_rate_calls_allows_specfied_calls
    1.upto(12) { @limiter.call_api }
    assert_equal 10,  @limiter.calls.size
  end

  def test_limit_rate_blocks_remaining_calls
    1.upto(12) { @limiter.call_api }
    assert_equal 2,  @limiter.calls_dropped.size
  end

  def test_it_does_not_block_if_they_are_well_distributed
    12.times do
      @limiter.call_api
      sleep(0.5)
    end
    assert_equal 12,  @limiter.calls.size
  end
end

class RateLimiter
  attr_reader :calls, :calls_dropped

  # Initializes the Rate Limiter.
  #
  # Takes the limit of calls per second to be allowed.
  #
  #   @limiter = RateLimiter.new(10)
  def initialize(limit = 10)
    @limit = limit
    @calls = []
    @calls_dropped = []
  end

  #
  # Entrypoint to try calling the API being subject to rate limiting.
  # Forwards the API call to the destination if allowed.
  #
  #   @limiter = RateLimiter.new(10)
  #   @limiter.call_api
  def call_api
    if rate_limited?
      @calls_dropped << Time.now.to_i
    else
      actually_call_api
      @calls << Time.now.to_i
    end
  end

  #
  # Checks if the call at that instant is subject to rate limiting.
  #
  def rate_limited?
    @calls.size >= @limit && (Time.now.to_i - @calls[-@limit]) < 1
  end

  #
  # Forwards the API call to the destination
  #
  def actually_call_api
    #puts "called API"
  end
end
