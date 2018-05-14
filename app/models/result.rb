class Result
  attr_accessor :code, :data, :error

  def initialize(args)
    return unless args.is_a?(Hash)

    args = args.with_indifferent_access

    @code = args[:code]
    @data = args[:data]
    @error = args[:error]
  end

  def ok?
    @error.nil? && @code.to_i.zero?
  end
end
