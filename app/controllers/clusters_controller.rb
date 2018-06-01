class ClustersController < ApplicationController
  before_action :set_cluster, only: [
    :show, :edit, :update, :servers, :unbind, :bind_server, :destroy
  ]

  def index
    @clusters = Cluster.all(after: after_index, limit: per_page)
  end

  def new
    @cluster = Cluster.new
  end

  def edit; end

  def update
    ok = @cluster.update(params)

    if ok
      redirect_to clusters_url, notice: '更新成功'
    else
      render :edit
    end
  end

  def create
    @cluster = Cluster.create(params)

    if @cluster.id
      redirect_to clusters_url
    else
      render :new
    end
  end

  def show; end

  def destroy
    begin
      @cluster.destroy!
      flash.notice = "Cluster #{@cluster.id}-#{@cluster.name} destroyed!"
    rescue => exp
      log(exp, 'clusters#destroy')
      flash.alert = exp.message
    end

    redirect_to clusters_url
  end

  def servers
    @servers = @cluster.servers
  end

  def unbind
    @cluster.unbind!

    redirect_to clusters_path
  end

  def bind_server
    if request.get?
      @servers = Server.all
      render text: render_to_string(layout: nil), layout: nil
      return
    end

    if @cluster.bind_server!(params[:server_id])
      redirect_to servers_cluster_path(@cluster.id)
    else
      render json: {msg: '绑定失败'}
    end
  end

  private

  def set_cluster
    @cluster = Cluster.find_by(id: params[:id])
  end
end
