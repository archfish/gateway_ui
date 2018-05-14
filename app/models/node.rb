class Node
  attr_accessor :cluster_id, :url_rewrite, :attr_name, :validations, :cache, :default_value, :use_default, :batch_index

  def initialize(args = {})
    @cluster_id = args[:cluster_id]
    @url_rewrite = args[:url_rewrite]
    @attr_name = args[:attr_name]
    @validations = args[:validations]
    @cache = args[:cache]
    @default_value = args[:default_value]
    @use_default = args[:use_default]
    @batch_index = args[:batch_index]
  end

  def default_value=(v)
    @default_value = DefaultValue.new(v)
  end

  def cluster=(v)
    @cluster = v.is_a?(Cluster) ? v : Cluster.new(v)

    self.cluster_id = @cluster.id
  end

  def cluster(rel = false)
    return nil if self.cluster_id.blank?
    return @cluster if !rel && @cluster && @cluster.id == self.cluster_id

    @cluster = Cluster.find_by(id: self.cluster_id)
  end

  def cache=(v)
    return if v.nil?
    @cache = v.is_a?(Cache) ? v : Cache.new(v)
  end

  class Cache
    attr_accessor :keys, :deadline, :conditions

    def initialize(args = {})
      self.keys = args[:keys]
      self.deadline = args[:deadline]
      self.conditions = args[:conditions]
    end
  end
end
