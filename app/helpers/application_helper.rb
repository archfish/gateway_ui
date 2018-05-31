module ApplicationHelper
  def navbar_list
    nlist = {
      Cluster: clusters_path,
      Server: servers_path,
      Routing: routings_path,
      Api: apis_path
    }
    nlist.map do |k, v|
      "<li class='#{ active_status(v) }'> #{link_to(k, v)} </li>"
    end
  end

  def render_pretty_json(v)
    data = JSON.pretty_unparse(v.try(:as_json) || {})
    line = data.scan("\n").count + 2
    "<textarea readonly class='form-control' style='border: 0px solid' rows=#{line}>#{data}</textarea>"
  end


  def active_status(v)
    if request.path =~ Regexp.new("^#{v}$|^#{v}[\/|\?].*")
      return 'active'
    end
  end
end
