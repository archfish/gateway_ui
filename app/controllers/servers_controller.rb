class ServersController < ApplicationController
  before_action :set_server, only: [:show, :edit, :update, :unbind, :destroy]

  def index
    @servers = Server.all(after: after_index, limit: per_page)
  end

  def new
    @server = Server.new
  end

  def edit; end
  def show; end

  def update
    res = @server.update(server_params)

    if res
      redirect_to servers_url, notice: '更新成功'
    else
      render :edit
    end
  end

  def create
    @server = Server.create(server_params)

    if @server.id
      redirect_to servers_url
    else
      render :new
    end
  end

  def destroy
    begin
      @server.destroy!
      flash.notice = "Server #{@server.id} destroyed!"
    rescue => exp
      log(exp, 'servers#destroy')
      flash.alert = exp.message
    end

    redirect_to servers_url
  end

  def unbind
    @server.unbind!(cluster_id: params[:cluster_id])
    redirect_to servers_cluster_path(params[:cluster_id])
  end

  private

  def set_server
    @server = Server.find_by(params.slice(:id))
  end

  def server_params
    if params[:heath_check].blank? || params[:heath_check].as_json.all?{|_, v| v.blank?}
      params[:heath_check] = nil
    end
    if params[:circuit_breaker].blank? || params[:circuit_breaker].as_json.all?{|_, v| v.blank?}
      params[:circuit_breaker] = nil
    end
    params
  end
end
