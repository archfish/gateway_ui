class RenderTemplate
  attr_accessor :objects

  def initialize(args = {})
    self.objects = args[:objects]
  end

  def objects=(v)
    return if v.nil?

    @objects = v.map{|x| x.is_a?(RenderObject) ? x : RenderObject.new(x) }
  end

  class RenderObject
    attr_accessor :name, :attrs, :flat_attrs

    def initialize(args = {})
      self.name = args[:name]
      self.attrs = args[:attrs]
      self.flat_attrs = args[:flat_attrs]
    end

    def attrs=(v)
      return if v.nil?
      @attrs = v.map{ |x| x.is_a?(Attr) ? x : Attr.new(x) }
    end
  end

  class Attr
    attr_accessor :name, :extract_exp

    def initialize(args = {})
      self.name = args[:name]
      self.extract_exp = args[:extract_exp]
    end
  end
end