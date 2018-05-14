class ApisController < ApplicationController
  def index
    @apis = Api.all(after: after_index, limit: per_page)
  end
end
