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
      render_record_error @session
    end
  end

  private

  def create_params
    authorized = %w{ user password }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end
end
