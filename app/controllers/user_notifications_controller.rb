class UserNotificationsController < ApplicationController
  before_action :authenticate

  def destroy
    @notification = UserNotification.where(user: current_user).find(params[:id])
    @notification.destroy
    head :no_content
  end

end
