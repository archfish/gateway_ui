class ClustersController < ApplicationController
  before_action :set_cluster, only: [:show, :edit, :update]

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

  def destroy
    redirect_to clusters_url if Cluster.destroy(params.slice(:id))
  end

  private

  def set_cluster
    @cluster = Cluster.find_by(id: params[:id])
  end
end
