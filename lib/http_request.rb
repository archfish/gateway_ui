module HttpRequest
  extend self

  def get(uri, params = {})
    load_json do
      RestClient::Request.execute(
        method: :get, url: get_url(uri),
        timeout: 1, open_timeout: 0.1,
        headers: {
          params: flat_map(params, :lower_camelize),
          content_type: 'application/json'
        }
      )
    end
  end

  def put(uri, payload = {})
    load_json do
      RestClient::Request.execute(
        method: :put, url: get_url(uri),
        timeout: 1, open_timeout: 0.1,
        payload: to_lower_camelize_json(payload),
        headers: {content_type: 'application/json'}
      )
    end
  end

  def delete(uri, payload = {})
    load_json do
      RestClient::Request.execute(
        method: :delete, url: get_url(uri),
        timeout: 1, open_timeout: 0.1,
        payload: to_lower_camelize_json(payload),
        headers: {content_type: 'application/json'}
      )
    end
  end

  private

  def load_json(&block)
    result = begin
      yield if block_given?
    rescue => e
      Rails.logger.debug("#{e} #{e.backtrace.take(15).join("\n")}")
      return Result.new(error: e.message)
    end

    Result.new(
      flat_map(
        JSON.parse(result)
      )
    )
  end

  def get_url(uri = '')
    @host ||= ENV['GATEWAY_BACKEND'] || 'localhost:9093'
    "http://#{@host}/v1#{uri}"
  end

  # type: [:underscore, :camelize, :lower_camelize]
  def flat_map(enum, type = :underscore)
    if enum.is_a?(Hash)
      enum.map { |k, v| [convert_key(k, type), flat_map(v, type)] }.to_h
    elsif enum.is_a?(Array)
      enum.map! { |i| flat_map(i, type) }
    else
      enum
    end
  end

  def convert_key(k, type)
    case type
    when :lower_camelize
      lower_camelize_tables(k) || k.to_s.public_send(:camelize, :lower)
    else
      k.to_s.public_send(type)
    end
  end

  def to_lower_camelize_json(params)
    flat_map(params, :lower_camelize).to_json
  end

  # 特殊小驼峰编码
  def lower_camelize_tables(k)
    kv = [
      [/_qps$/, 'QPS'],
      [/_qps_/, 'QPS_'],
      [/_id$/, 'ID'],
      [/_id_/, 'ID']
    ]
    has_changed = false
    kv.each do |x|
      next unless x.first =~ k.to_s
      has_changed = true
      k = k.to_s.sub(x.first, x.last)
    end

    return k if has_changed

    nil
  end

end
