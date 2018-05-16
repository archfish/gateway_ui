class IpAccessControl
  attr_accessor :whitelist, :blacklist

  def initialize(args = {})
    self.whitelist = args[:whitelist]
    self.blacklist = args[:blacklist]
  end

  # array or string
  [:whitelist, :blacklist].each do |x|
    define_method("#{x}=") do |v|
      return if v.nil?
      instance_variable_set("@#{x}", v.is_a?(String) ? v.split(',').map(&:strip) : v)
    end
  end
end
