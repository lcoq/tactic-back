class SessionsController < ApplicationController
  before_action :authenticate, only: :show

  def show
    render json: @current_session, include: show_include_params
  end

  def create
    @session = Session.new_with_generated_token(create_session_params)
    if @session.save
      render json: @session, include: create_include_params
    else
      render_record_error @session
    end
  end

  private

  def create_session_params
    authorized = %w{ user password }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end

  def create_include_params
    authorized = %w{ user user.configs }
    include = params['include']
    include if include.present? && (include.split(',') - authorized).empty?
  end

  def show_include_params
    authorized = %w{ user user.configs }
    include = params['include']
    include if include.present? && (include.split(',') - authorized).empty?
  end

end
