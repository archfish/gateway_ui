class ApisController < ApplicationController
  before_action :set_api, only: [:edit, :update]

  def index
    @apis = Api.all(after: after_index, limit: per_page)
  end

  def new
    @api = Api.new
  end

  def edit; end

  def create

  end

  def update

  end

  private

  def set_api
    @api = Api.find_by(params.slice(:id))
  end
end
