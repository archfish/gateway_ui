class RoutingsController < ApplicationController
  before_action :set_routing, only: [:show, :edit, :update, :destroy]
  before_action :get_related_list, only: [:new, :edit]

  def index
    @routings = Routing.all(after: after_index, limit: per_page)
  end

  def new
    @routing = Routing.new
  end

  def edit; end
  def show; end

  def update
    res = @routing.update(params)

    if res
      redirect_to routings_url, notice: '更新成功'
    else
      render :edit
    end
  end

  def create
    @routing = Routing.create(params)

    if @routing.id
      redirect_to routings_url
    else
      render :new
    end
  end

  def destroy
    begin
      @routing.destroy!
      flash.notice = "Routing #{@routing.id} destroyed!"
    rescue => exp
      log(exp, 'routings#destroy')
      flash.alert = exp.message
    end

    redirect_to routings_url
  end

  private

  def set_routing
    @routing = Routing.find_by(params.slice(:id))
  end

  def get_related_list
    @apis = Api.all
    @clusters = Cluster.all
  end
end
