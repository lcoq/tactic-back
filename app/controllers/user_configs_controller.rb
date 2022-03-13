class UserConfigsController < ApplicationController
  before_action :authenticate
  before_action :ensure_user_id_is_current_id

  def index
    @configs = UserConfig.list_for_user(current_user)
    render json: @configs
  end

  def update
    @config = UserConfig.find_for_user(current_user, params[:id])
    if @config.update_value(update_params[:value])
      render json: @config
    else
      # TODO ?
    end
  end

  private

  def ensure_user_id_is_current_id
    if params[:user_id].to_s != current_user.id.to_s
      render_forbidden
      return false
    end
  end

  def update_params
    authorized = %w{ value }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end
end
