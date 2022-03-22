class UserNotificationListsController < ApplicationController
  before_action :authenticate
  before_action :ensure_user_id_is_current_id

  def latest
    @list = UserNotificationList.latest(current_user)
    render json: @list, include: index_include_params
  end

  def update
    @list = UserNotificationList.find_for_user(current_user, params[:id])
    if @list.update_attributes(update_params)
      render json: @list, include: 'notifications'
    else
      render_record_error @list
    end
  end

  private

  def ensure_user_id_is_current_id
    if params[:user_id].to_s != current_user.id.to_s
      render_forbidden
      return false
    end
  end

  def index_include_params
    authorized = %w{ notifications notifications.resource }
    include = index_params['include']
    include if include.present? && (include.split(',') - authorized).empty?
  end

  def index_params
    params.permit('include')
  end

  def update_params
    authorized = %w{ status }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end
end
