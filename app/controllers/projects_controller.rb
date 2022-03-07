class ProjectsController < ApplicationController
  before_action :authenticate

  def index
    if query?
      @projects = Project.active.search_by_name(query_params).includes(:client)
    else
      @projects = Project.active.order(:name).includes(:client)
    end
    render json: @projects, include: include_params
  end

  # needed for current month entries which includes project.
  # maybe we should instead remove project details from those entries
  def show
    @project = Project.find(params[:id])
    render json: @project
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

  def include_params
    authorized = %w{ client }
    include = index_params['include']
    include if include.present? && (include.split(',') - authorized).empty?
  end

  def index_params
    params.permit('include', 'filter' => 'query')
  end

  def create_params
    authorized = %w{ name client }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end

  def update_params
    authorized = %w{ name client }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end
end
