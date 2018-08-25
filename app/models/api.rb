class Api
  include Concerns::Enum

  def self.attributes
    [
      :id, :name, :url_pattern, :method, :domain, :status, :ip_access_control,
      :default_value, :nodes, :auth_filter, :perms, :render_template, :use_default,
      :position, :match_rule, :tags, :web_socket_options
    ]
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

  [:id, :status, :position, :match_rule].each do |x|
    define_method "#{x}=".to_sym do |v|
      instance_variable_set("@#{x}", v.try(:to_i))
    end
  end

  def status_name
    key_of_status(self.status)
  end

  def match_rule_name
    key_of_match_rule(self.match_rule)
  end

  def default_value=(v)
    return @default_value = nil if v.nil?
    @default_value = v.is_a?(DefaultValue) ? v : DefaultValue.new(v)
  end

  def nodes=(v)
    return @nodes = nil if v.nil?
    @nodes = v.map{ |x| x.is_a?(Node) ? x : Node.new(x) }
  end

  def render_template=(v)
    return @render_template = nil if v.nil?
    @render_template = RenderTemplate.new(v)
  end

  def ip_access_control=(v)
    return @ip_access_control = nil if v.nil?
    @ip_access_control = v.is_a?(IpAccessControl) ? v : IpAccessControl.new(v)
  end

  def perms=(v)
    return @perms = nil if v.nil?
    @perms = v.is_a?(String) ? v.split(',').map(&:strip) : v
  end

  def use_default=(v)
    @use_default = v.is_a?(String) ? v.casecmp('true').zero? : v
  end

  def tags=(v)
    return @tags = nil if v.nil?
    @tags = v.map{ |x| x.is_a?(PairValue) ? x : PairValue.new(x) }
  end

  def web_socket_options=(v)
    return @web_socket_options = nil if v.nil?
    @web_socket_options = WebSocketOptions.new(v)
  end

  def update(options = {})
    options.each_pair do |k, v|
      public_send("#{k}=", v) if respond_to?("#{k}=")
    end
    result = HttpRequest.put('/apis', self.as_json)

    result.ok?
  end

  def destroy!
    raise '已关联Routing，请先删除相关路由！' if Routing.include_api_id?(id)

    result = HttpRequest.delete("/apis/#{id}")
    result.ok?
  end

  class << self
    def all(options = {})
      result = HttpRequest.get('/apis', options)

      return [] unless result.ok?

      (result.data || []).map{|x| self.new(x)}
    end

    def find_by(options)
      result = HttpRequest.get("/apis/#{options[:id]}")

      return nil unless result.ok?

      self.new(result.data)
    end

    def create(options = {})
      api = self.new(options)
      result = HttpRequest.put('/apis', api.as_json)

      return api unless result.ok?

      api.id = result.data.to_i

      api
    end

    def include_cluster_id?(cluster_id)
      last_id = 0
      loop do
        apis = self.all(after: last_id, limit: 10)
        break if apis.blank?
        last_id = apis.max{|x| x.id}
        has_use = apis.any? do |api|
          (api.nodes || []).any?{|node| node.cluster_id.to_i == cluster_id.to_i}
        end

        return true if has_use
      end

      false
    end
  end

  class WebSocketOptions
    def self.attributes
      [
        :origin
      ]
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
  end
end
