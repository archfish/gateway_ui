class RoutingsController < ApplicationController
  before_action :set_routing, only: [:edit, :update]

  def index
    @routings = Routing.all(after: after_index, limit: per_page)
  end

  def new
    @routing = Routing.new
  end

  def edit; end

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
    redirect_to routings_url if Routing.destroy(params.slice(:id))
  end

  private

  def set_routing
    @routing = Routing.find_by(params.slice(:id))
  end
end