class HeathCheck
  attr_accessor :path, :body, :check_interval, :timeout

  def initialize(args = {})
    args ||= {}

    @path = args[:path]
    @body = args[:body]
    @check_interval = args[:check_interval].try(:to_i)
    @timeout = args[:timeout].try(:to_i)
  end
end
