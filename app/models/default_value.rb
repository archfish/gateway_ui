class DefaultValue
  attr_accessor :body, :headers, :cookies

  def initialize(args = {})
    return if args.nil?
    self.body = args[:body]
    self.headers = args[:headers]
    self.cookies = args[:cookies]
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
    attr_accessor :name, :value

    def initialize(args = {})
      self.name = args[:name]
      self.value = args[:value]
    end
  end

  class Cookie < Header
  end
end
