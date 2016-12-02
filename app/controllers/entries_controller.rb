class EntriesController < ApplicationController
  before_action :authenticate

  def index
    @entries = current_user.recent_entries.includes(:project)
    render json: @entries, include: include_params
  end

  private

  def include_params
    authorized = %w{ project }
    include = params.permit(:include)[:include]
    include if include.present? && (include.split(',') - authorized).empty?
  end
end
