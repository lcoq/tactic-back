class EntriesController < ApplicationController
  before_action :authenticate

  def index
    @entries = current_user.recent_entries
    render json: @entries
  end
end
