class CircuitBreaker
  attr_accessor :close_timeout, :half_traffic_rate, :rate_check_period, :failure_rate_to_close,
                :succeed_rate_to_open

  def initialize(args = {})
    args ||= {}
    @close_timeout = args[:close_timeout].try(:to_i)
    @half_traffic_rate = args[:half_traffic_rate].try(:to_i)
    @rate_check_period = args[:rate_check_period].try(:to_i)
    @failure_rate_to_close = args[:failure_rate_to_close].try(:to_i)
    @succeed_rate_to_open = args[:succeed_rate_to_open].try(:to_i)
  end
end
