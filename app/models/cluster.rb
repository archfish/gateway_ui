class Cluster
  include Concerns::Enum

  attr_accessor :id, :name, :load_balance

  def initialize(args = {})
    args ||= {}
    @id = args[:id].to_i
    @name = args[:name]
    @load_balance = args[:load_balance]
  end

  def lb
    key_of_lb(@load_balance)
  end

  def to_api_options
    result = {}
    result[:id] = @id
    result[:name] = @name if @name.present?
    result[:load_balance] = @load_balance.to_i if @load_balance.present?

    result
  end

  def update(options = {})
    @name = options[:name] if options.include?(:name)
    @load_balance = options[:load_balance] if options.include?(:load_balance)

    result = HttpRequest.put('/clusters', self.to_api_options)

    result.ok?
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
      result = HttpRequest.put('/clusters', cluster.to_api_options)

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
