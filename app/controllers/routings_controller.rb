class RoutingsController < ApplicationController
  before_action :set_routing, only: [:show, :edit, :update, :destroy]
  before_action :get_related_list, only: [:new, :edit]
  before_action :set_schema, only: [:new, :edit]

  def index
    @routings = Routing.all(after: after_index, limit: per_page)
  end

  def new
    @routing = Routing.new
  end

  def edit; end
  def show; end

  def update
    ok = @routing.update(routing_params)

    if ok
      render json: {url: routings_url}, status: 301
    else
      render json: {msg: '更新失败'}
    end
  end

  def create
    @routing = Routing.create(routing_params)

    if @routing.id
      render json: {url: routings_url}, status: 301
    else
      render json: {msg: '创建失败'}
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

  def routing_params
    params.require(:routing)
  end

  def set_schema
    @routing_schema = <<-ROUTING
    {
      "type": "object",
      "format": "grid",
      "properties": {
        "name": {
          "type": "string",
          "title": "Name",
          "minLength": 5,
          "options": {
            "grid_columns": 4
          },
          "propertyOrder": 10
        },
        "strategy": {
          "type": "integer",
          "title": "Strategy",
          "enum": #{Routing::Strategy.values},
          "options": {
            "grid_columns": 4,
            "enum_titles": #{Routing::Strategy.keys.map(&:to_s)}
          },
          "propertyOrder": 20
        },
        "traffic_rate": {
          "type": "integer",
          "title": "trafficRate",
          "options": {
            "grid_columns": 4
          },
          "minimum": 0,
          "maximum": 100,
          "propertyOrder": 30
        },
        "status": #{JsonSchema.status(40)},
        "cluster_id": #{JsonSchema.cluster_id(50)},
        "api": #{JsonSchema.api(60)},
        "conditions": #{JsonSchema.conditions(100)}
      },
      "required": [
        "cluster_id", "strategy", "api", "status", "name", "traffic_rate"
      ]
    }
    ROUTING
  end

end
