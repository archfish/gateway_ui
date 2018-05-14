class DefaultValue
  attr_accessor :body, :headers

  def initialize(args = {})
    self.body = args[:body]
    self.headers = args[:headers]
  end

  def headers=(v)
    return if v.nil?
    @headers = v.map{|x| Header.new(x)}
  end

  class Header
    attr_accessor :name, :value

    def initialize(args = {})
      self.name = args[:name]
      self.value = args[:value]
    end
  end
end
