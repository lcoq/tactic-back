class ProjectsController < ApplicationController
  before_action :authenticate

  def index
    @projects = Project.search_by_name(query_params)
    render json: @projects
  end

  private

  def query_params
    params.require('filter').require('query')
  end
end
