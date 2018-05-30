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

  def body=(v)
    return @body = nil if v.nil?
    @body = (base64_encode?(v) ? v : Base64.encode64(v)).strip
  end

  def body
    return if @body.nil?
    Base64.decode64(@body)
  end

  def headers=(v)
    return @headers = nil if v.nil?
    @headers = v.map{ |x| Header.new(x) }
  end

  def cookies=(v)
    return @cookies = nil if v.nil?
    @cookies = v.map{ |x| Cookie.new(x) }
  end

  private
  def base64_encode?(v)
    v =~ /^([A-Za-z0-9+\/]{4})*([A-Za-z0-9+\/]{4}|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==)$/
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
