class Server
  include Concerns::Enum

  def self.attributes
    [:id, :addr, :protocol, :max_qps, :heath_check, :circuit_breaker]
  end

  def self.attribute_names
    attributes.map(&:to_s)
  end

  attr_accessor *attributes

  def initialize(args = {})
    args ||= {}
    self.class.attributes.each do |x|
      self.public_send("#{x}=", args[x])
    end
  end

  def protocol_name
    key_of_pt(protocol)
  end

  def name
    "#{self.addr}-#{self.protocol_name}"
  end

  [:id, :max_qps, :protocol].each do |x|
    define_method "#{x}=".to_sym do |v|
      instance_variable_set("@#{x}", v.try(:to_i))
    end
  end

  def heath_check=(v)
    @heath_check = v.nil? ? nil : HeathCheck.new(v)
  end

  def circuit_breaker=(v)
    @circuit_breaker = v.nil? ? nil : CircuitBreaker.new(v)
  end

  def update(options = {})
    options.each_pair do |k, v|
      public_send("#{k}=", v) if respond_to?("#{k}=")
    end

    result = HttpRequest.put('/servers', self.as_json)

    result.ok?
  end

  # options
  #   cluster_id required
  def unbind!(options)
    opt = {
      cluster_id: options[:cluster_id].to_i,
      server_id: self.id
    }
    HttpRequest.delete('/binds', opt).ok?
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

  class HeathCheck
    def self.attributes
      [:path, :body, :check_interval, :timeout]
    end

    def self.attribute_names
      attributes.map(&:to_s)
    end

    attr_accessor *attributes

    def self.need_convert_to_second
      [:check_interval, :timeout]
    end

    def initialize(args = {})
      args ||= {}

      self.class.attributes.each do |x|
        self.public_send("#{x}=", args[x])
      end

      self.class.need_convert_to_second.each do |x|
        mt = "#{x}_in_second".to_sym
        self.public_send("#{mt}=", args[mt])
      end
    end

    [:check_interval, :timeout].each do |x|
      define_method "#{x}=".to_sym do |v|
        instance_variable_set("@#{x}", v.try(:to_i))
      end
    end

    need_convert_to_second.each do |x|
      define_method "#{x}_in_second=".to_sym do |v|
        next if v.blank?
        self.public_send("#{x}=", (v.to_f * 10 ** 9).to_i)
      end

      define_method "#{x}_in_second".to_sym do
        t = self.public_send("#{x}")
        return if t.nil?
        t.to_f / (10 ** 9)
      end
    end
  end

  class CircuitBreaker
    def self.attributes
      [
        :close_timeout, :half_traffic_rate, :rate_check_period,
        :failure_rate_to_close, :succeed_rate_to_open
      ]
    end

    def self.attribute_names
      attributes.map(&:to_s)
    end

    attr_accessor *attributes

    def self.need_convert_to_second
      [:close_timeout, :rate_check_period]
    end

    def initialize(args = {})
      args ||= {}

      self.class.attributes.each do |x|
        self.public_send("#{x}=", args[x])
      end

      self.class.need_convert_to_second.each do |x|
        mt = "#{x}_in_second".to_sym
        self.public_send("#{mt}=", args[mt])
      end
    end

    [
      :close_timeout, :half_traffic_rate, :rate_check_period,
      :failure_rate_to_close, :succeed_rate_to_open
    ].each do |x|
      define_method "#{x}=".to_sym do |v|
        instance_variable_set("@#{x}", v.try(:to_i))
      end
    end


    need_convert_to_second.each do |x|
      define_method "#{x}_in_second=".to_sym do |v|
        next if v.blank?
        self.public_send("#{x}=", (v.to_f * 10 ** 9).to_i)
      end

      define_method "#{x}_in_second".to_sym do
        t = self.public_send("#{x}")
        return if t.nil?
        t.to_f / (10 ** 9)
      end
    end
  end
end
