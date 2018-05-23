class IpAccessControl
  def self.attributes
    [:whitelist, :blacklist]
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

  # array or string
  [:whitelist, :blacklist].each do |x|
    define_method("#{x}=") do |v|
      return if v.nil?
      instance_variable_set("@#{x}", v.is_a?(String) ? v.split(',').map(&:strip) : v)
    end
  end
end
