class Api
  include Concerns::Enum

  attr_accessor :id, :name, :url_pattern, :method, :domain, :status, :ip_access_control,
                :default_value, :nodes, :auth_filter, :perms, :render_template, :use_default

  def initialize(args = {})
    self.id = args[:id]
    self.name = args[:name]
    self.url_pattern = args[:url_pattern]
    self.method = args[:method]
    self.domain = args[:domain]
    self.status = args[:status]
    self.ip_access_control = args[:ip_access_control]
    self.default_value = args[:default_value]
    self.nodes = args[:nodes]
    self.auth_filter = args[:auth_filter]
    self.perms = args[:perms]
    self.render_template = args[:render_template]
    self.use_default = args[:use_default]
  end

  def status=(v)
    @status = v.try(:to_i)
  end

  def status_name
    key_of_status(self.status)
  end

  def default_value=(v)
    @default_value = DefaultValue.new(v)
  end

  def nodes=(v)
    return if v.nil?
    @nodes = v.map{ |x| x.is_a?(Node) ? x : Node.new(x) }
  end

  def render_template=(v)
    return if v.nil?
    @render_template = RenderTemplate.new(v)
  end

  class << self
    def all(options)
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

    # options
    #   id required
    def destroy(options = {})
      # TODO add checker
      result = HttpRequest.delete("/apis/#{options[:id]}")
      result.ok?
    end
  end
end
