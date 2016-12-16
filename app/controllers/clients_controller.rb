class ClientsController < ApplicationController
  before_action :authenticate

  def index
    @clients = Client.active.order(:name).includes(:projects)
    render json: @clients, include: include_params
  end

  def create
    @client = Client.new
    if @client.update_attributes(create_params)
      render json: @client
    else
      render_record_error @client
    end
  end

  def update
    @client = Client.find(params[:id])
    if @client.update_attributes(update_params)
      render json: @client
    else
      render_record_error @client
    end
  end

  def destroy
    @client = Client.find(params[:id])
    @client.archive
    render json: @client
  end

  private

  def include_params
    authorized = %w{ projects }
    include = index_params['include']
    include if include.present? && (include.split(',') - authorized).empty?
  end

  def index_params
    params.permit('include')
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
