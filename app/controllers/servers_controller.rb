class ServersController < ApplicationController
  before_action :set_server, only: [:edit, :update, :unbind]

  def index
    @servers = Server.all(after: after_index, limit: per_page)
  end

  def new
    @server = Server.new
  end

  def edit; end

  def update
    res = @server.update(params)

    if res
      redirect_to servers_url, notice: '更新成功'
    else
      render :edit
    end
  end

  def create
    @server = Server.create(params)

    if @server.id
      redirect_to servers_url
    else
      render :new
    end
  end

  def destroy
    redirect_to servers_url if Server.destroy(params.slice(:id))
  end

  def unbind
    @server.unbind!(cluster_id: params[:cluster_id])
    redirect_to servers_cluster_path(params[:cluster_id])
  end

  private

  def set_server
    @server = Server.find_by(params.slice(:id))
  end
end
