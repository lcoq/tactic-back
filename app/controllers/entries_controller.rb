class EntriesController < ApplicationController
  before_action :authenticate

  def index
    if current_week?
      @entries = Entry.in_current_week.includes(:project, :user)
    elsif entry_filters?
      @entries = Entry.filter(entry_filters).includes(:project, :user)
    else
      @entries = current_user.recent_entries.includes(:project)
    end
    render json: @entries, include: include_params
  end

  def create
    @entry = Entry.new(user: current_user)
    if @entry.update_attributes(create_params)
      render json: @entry
    else
      render json: @entry, status: :unprocessable_entity, serializer: ActiveModel::Serializer::ErrorSerializer
    end
  end

  def update
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(update_params)
      render json: @entry
    else
      render json: @entry, status: :unprocessable_entity, serializer: ActiveModel::Serializer::ErrorSerializer
    end
  end

  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy
    render json: @entry
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
    return unless index_filters
    index_filters['current-week']
  end

  def entry_filters?
    return unless index_filters
    required = %w{ since before }
    (required - index_filters.keys).empty?
  end

  def entry_filters
    project_ids = index_filters['project-id']
    project_ids << nil if project_ids && project_ids.delete('0')
    {
      user_ids: index_filters['user-id'],
      project_ids: project_ids,
      since: Time.zone.parse(index_filters['since']),
      before: Time.zone.parse(index_filters['before'])
    }
  end

  def index_filters
    index_params['filter']
  end

  def index_params
    filters = [
      'current-week',
      'since',
      'before',
      { 'user-id' => [] },
      { 'project-id' => [] }
    ]
    params.permit('include', 'filter' => filters)
  end

  def update_params
    authorized = %w{ title started-at stopped-at project }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end

  def create_params
    authorized = %w{ title started-at stopped-at project }
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
  end
end
