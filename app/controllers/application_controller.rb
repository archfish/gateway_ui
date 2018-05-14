class ApplicationController < ActionController::Base
  private

  def after_index
    (params[:after] || 0).to_i
  end

  def per_page
    @per_page = (params[:per_page] || 10).to_i
  end
end
