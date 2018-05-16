class Server
  include Concerns::Enum

  attr_accessor :id, :addr, :protocol, :max_qps, :heath_check, :circuit_breaker

  def initialize(args = {})
    args ||= {}
    self.id = args[:id]
    @addr = args[:addr]
    self.protocol = args[:protocol]
    self.max_qps = args[:max_qps]
    self.heath_check = args[:heath_check]
    self.circuit_breaker = args[:circuit_breaker]
  end

  def protocol_name
    key_of_pt(@protocol)
  end

  def id=(v)
    @id = v.try(:to_i)
  end

  def heath_check=(v)
    @heath_check = HeathCheck.new(v || {})
  end

  def circuit_breaker=(v)
    @circuit_breaker = CircuitBreaker.new(v || {})
  end

  def max_qps=(v)
    @max_qps = v.try(:to_i)
  end

  def protocol=(v)
    @protocol = v.try(:to_i)
  end

  def update(options = {})
    options.each_pair do |k, v|
      public_send("#{k}=", v) if respond_to?("#{k}=")
    end
    result = HttpRequest.put('/servers', self.as_json)

    result.ok?
  end

  class << self
    def all(options = {})
      result = HttpRequest.get('/servers', options)

      return [] unless result.ok?

      (result.data || []).map{|x| self.new(x)}
    end

    def find_by(options)
      result = HttpRequest.get("/servers/#{options[:id]}")

      return nil unless result.ok?

      Server.new(result.data)
    end

    def create(options = {})
      server = self.new(options)
      result = HttpRequest.put('/servers', server.as_json)

      return server unless result.ok?

      server.id = result.data.to_i

      server
    end

    # options
    #   id required
    def destroy(options = {})
      # TODO add checker
      result = HttpRequest.delete("/servers/#{options[:id]}")
      result.ok?
    end
  end
end