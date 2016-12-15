class ProjectsController < ApplicationController
  before_action :authenticate

  def index
    if query?
      @projects = Project.active.search_by_name(query_params)
    else
      @projects = Project.active.order(:name)
    end
    render json: @projects
  end

  def create
    @project = Project.new
    if @project.update_attributes(create_params)
      render json: @project
    else
      render_record_error @project
    end
  end

  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(update_params)
      render json: @project
    else
      render_record_error @project
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.archive
    render json: @project
  end

  private

  def query_params
    index_params['filter'] && index_params['filter']['query']
  end

  def query?
    query_params
  end

  def index_params
    params.permit('filter' => 'query')
  end

  def create_params
    authorized = %w{ name }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end

  def update_params
    authorized = %w{ name }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end
end
