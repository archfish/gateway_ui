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

  def active_status(v)
    if request.path =~ Regexp.new("^#{v}$|^#{v}[\/|\?].*")
      return 'active'
    end
  end
end
