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

  def validations=(v)
    return if v.nil?
    @validations = v.map{ |x| x.is_a?(Validation) ? x : Validation.new(x) }
  end

  class Cache
    attr_accessor :keys, :deadline, :conditions

    def initialize(args = {})
      self.keys = args[:keys]
      self.deadline = args[:deadline]
      self.conditions = args[:conditions]
    end
  end

  class Validation
    attr_accessor :parameter, :required, :rules

    def initialize(args = {})
      self.parameter = args[:parameter]
      self.required = args[:required]
      self.rules = args[:rules]
    end

    def parameter=(v)
      return if v.nil?

      @parameter = v.is_a?(Parameter) ? v : Parameter.new(v)
    end

    def rules=(v)
      return if v.nil?

      @rules = v.map{ |x| x.is_a?(ValidationRule) ? x : ValidationRule.new(x) }
    end
  end

  class Parameter
    attr_accessor :name, :source, :index

    def initialize(args = {})
      self.name = args[:name]
      self.source = args[:source]
      self.index = args[:index]
    end
  end

  class ValidationRule
    attr_accessor :rule_type, :expression

    def initialize(args= {})
      self.rule_type = args[:rule_type]
      self.expression = args[:expression]
    end
  end
end
