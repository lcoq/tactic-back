class EntriesController < ApplicationController
  before_action :authenticate

  def index
    if current_week?
      @entries = Entry.in_current_week.includes(:project, :user)
    else
      @entries = current_user.recent_entries.includes(:project)
    end
    render json: @entries, include: include_params
  end

  private

  def include_params
    authorized = %w{ project }
    include = index_params['include']
    include if include.present? && (include.split(',') - authorized).empty?
  end

  def current_week?
    current_week_params == '1'
  end

  def current_week_params
    index_params['filter'] && index_params['filter']['current-week']
  end

  def index_params
    params.permit('include', 'filter' => 'current-week')
  end
end
