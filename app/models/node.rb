class Node
  def self.attributes
    [
      :cluster_id, :url_rewrite, :attr_name, :validations, :cache,
      :default_value, :use_default, :batch_index
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
    def self.attributes
      [
        :keys, :deadline, :conditions
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

  class Validation
    def self.attributes
      [
        :parameter, :required, :rules
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
    def self.attributes
      [
        :name, :source, :index
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

  class ValidationRule
    def self.attributes
      [
        :rule_type, :expression
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
