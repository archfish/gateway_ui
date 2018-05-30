class RenderTemplate
  def self.attributes
    [:objects]
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

  def objects=(v)
    return @objects = nil if v.nil?

    @objects = v.map{|x| x.is_a?(RenderObject) ? x : RenderObject.new(x) }
  end

  class RenderObject
    def self.attributes
      [
        :name, :attrs, :flat_attrs
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

    def attrs=(v)
      return @attrs = nil if v.nil?
      @attrs = v.map{ |x| x.is_a?(Attr) ? x : Attr.new(x) }
    end
  end

  class Attr
    def self.attributes
      [
        :name, :extract_exp
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
