class EntriesStatGroupsController < ApplicationController
  before_action :authenticate

  def daily
    if entry_daily_filters?
      @entries_stat_group = EntriesStatGroupBuilder.daily(entry_daily_filters)
      render json: @entries_stat_group, include: 'entries_stats'
    else
      head :unprocessable_entity
    end
  end

  def monthly
    if entry_monthly_filters?
      @entries_stat_group = EntriesStatGroupBuilder.monthly(entry_monthly_filters)
      render json: @entries_stat_group, include: 'entries_stats'
    else
      head :unprocessable_entity
    end
  end

  private

  def entry_monthly_filters?
    return unless index_filters
    required = %w{ since before }
    (required - index_filters.keys).empty?
  end

  def entry_monthly_filters
    project_ids = index_filters['project-id']
    project_ids << nil if project_ids && project_ids.delete('0')
    {
      user_ids: index_filters['user-id'],
      project_ids: project_ids,
      since: Time.zone.parse(index_filters['since']),
      before: Time.zone.parse(index_filters['before']),
      query: index_filters['query']
    }
  end

  def entry_daily_filters?
    return unless index_filters
    required = %w{ since before }
    (required - index_filters.keys).empty?
  end

  def entry_daily_filters
    project_ids = index_filters['project-id']
    project_ids << nil if project_ids && project_ids.delete('0')
    {
      user_ids: index_filters['user-id'],
      project_ids: project_ids,
      since: Time.zone.parse(index_filters['since']),
      before: Time.zone.parse(index_filters['before']),
      query: index_filters['query']
    }
  end

  def index_filters
    index_params['filter']
  end

  def index_params
    filters = [
      'since',
      'before',
      'query',
      { 'user-id' => [] },
      { 'project-id' => [] }
    ]
    params.permit('filter' => filters)
  end
end
