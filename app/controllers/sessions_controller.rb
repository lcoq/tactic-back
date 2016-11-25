class SessionsController < ApplicationController

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
end
