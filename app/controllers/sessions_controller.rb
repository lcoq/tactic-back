class SessionsController < ApplicationController
  before_action :authenticate, only: :show

  def show
    render json: @current_session
  end

  def create
    @session = Session.new_with_generated_token(create_params)
    if @session.save
      render json: @session
    else
      render json: @session, status: :unprocessable_entity, serializer: ActiveModel::Serializer::ErrorSerializer
    end
  end

  private

  def create_params
    authorized = %w{ user }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end

  def authenticate
    token = request.headers['Authorization']
    @current_session = token.presence && Session.find_by(token: token)
    unless @current_session
      render json: {}, status: :forbidden
      return false
    end
  end
end
