class DefaultValue
  def self.attributes
    [:body, :headers, :cookies]
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

  def headers=(v)
    return if v.nil?
    @headers = v.map{ |x| Header.new(x) }
  end

  def cookies=(v)
    return if v.nil?
    @cookies = v.map{ |x| Cookie.new(x) }
  end

  class Header
    def self.attributes
      [:name, :value]
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

  class Cookie < Header
  end
end
