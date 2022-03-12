class UsersController < ApplicationController
  before_action :authenticate, except: :index
  before_action :ensure_id_is_current_id, except: :index

  def index
    @users = User.all
    render json: @users
  end

  def show
    @user = current_user
    render json: @user
  end

  def update
    @user = current_user
    if @user.update_attributes(update_params)
      render json: @user
    else
      render_record_error @user
    end
  end

  private

  def ensure_id_is_current_id
    if params[:id].to_s != current_user.id.to_s
      render_forbidden
      return false
    end
  end

  def update_params
    authorized = %w{ name password }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end

end
