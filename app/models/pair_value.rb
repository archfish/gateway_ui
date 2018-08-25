class PairValue
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
