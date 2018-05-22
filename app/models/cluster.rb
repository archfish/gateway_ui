class Cluster
  include Concerns::Enum

  attr_accessor :id, :name, :load_balance

  def initialize(args = {})
    args ||= {}
    self.id = args[:id]
    self.name = args[:name]
    self.load_balance = args[:load_balance]
  end

  [:id, :load_balance].each do |x|
    define_method "#{x}=".to_sym do |v|
      instance_variable_set("@#{x}", v.try(:to_i))
    end
  end

  def lb
    key_of_lb(@load_balance)
  end

  def update(options = {})
    options.each_pair do |k, v|
      public_send("#{k}=", v) if respond_to?("#{k}=")
    end

    HttpRequest.put('/clusters', self.as_json).ok?
  end

  # 获取一个cluster绑定的server列表
  def servers
    result = HttpRequest.get("/clusters/#{self.id}/binds")
    return [] unless result.ok?

    (result.data || []).map do |server_id|
      next if server_id.to_i.zero?
      Server.find_by(id: server_id)
    end.compact
  end

  # 解绑所有服务，过程不可逆
  def unbind!
    HttpRequest.delete("/clusters/#{self.id}/binds").ok?
  end

  def bind_server!(server_id)
    options = {
      cluster_id: self.id,
      server_id: server_id.try(:to_i)
    }
    HttpRequest.put('/binds', options).ok?
  end

  class << self
    def all(options = {})
      result = HttpRequest.get('/clusters', options)

      return [] unless result.ok?

      (result.data || []).map{|x| self.new(x)}
    end

    # options
    #   id integer/string required
    def find_by(options)
      result = HttpRequest.get("/clusters/#{options.delete(:id)}", options)

      return nil unless result.ok?

      Cluster.new(result.data)
    end

    def create(options)
      cluster = self.new(options)
      result = HttpRequest.put('/clusters', cluster.as_json)

      return cluster unless result.ok?

      cluster.id = result.data.to_i

      cluster
    end

    # options
    #   id required
    def destroy(options = {})
      # TODO add checker
      result = HttpRequest.delete("/clusters/#{options[:id]}")
      result.ok?
    end
  end
end
