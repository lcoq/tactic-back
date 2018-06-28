class EntriesController < ApplicationController
  include ActionController::MimeResponds

  before_action :authenticate, except: :index
  before_action :authenticate_from_headers_or_params, only: :index

  def index
    if current_week? || current_month?
      @entries = find_entries_in_current_week_or_month
    elsif entry_filters?
      @entries = Entry.filter(entry_filters).stopped.includes(:project, :user)
    else
      @entries = current_user.recent_entries.stopped.includes(:project, :user)
    end
    respond_to do |format|
      format.csv { send_data EntryCSV.new(@entries).generate }
      format.any { render json: @entries, include: index_include_params }
    end
  end

  def running
    @entry = current_user.running_entry
    if @entry
      render json: @entry, include: running_include_params
    else
      render json: { data: nil }
    end
  end

  def create
    @entry = Entry.new(user: current_user)
    if @entry.update_attributes(create_params)
      render json: @entry
    else
      render_record_error @entry
    end
  end

  def update
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(update_params)
      render json: @entry
    else
      render_record_error @entry
    end
  end

  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy
    render json: @entry
  end

  private

  def index_include_params
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

  def current_month?
    current_month_params == '1'
  end

  def current_month_params
    return unless index_filters
    index_filters['current-month']
  end

  def filter_user_id
    return unless index_filters
    index_filters['user-id']
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
      before: Time.zone.parse(index_filters['before']),
      query: index_filters['query']
    }
  end

  def index_filters
    index_params['filter']
  end

  def index_params
    filters = [
      'current-week',
      'current-month',
      'since',
      'before',
      'query',
      { 'user-id' => [] },
      { 'project-id' => [] }
    ]
    params.permit('Authorization', 'format', 'include', 'filter' => filters)
  end

  def running_include_params
    authorized = %w{ project }
    include = running_params['include']
    include if include.present? && (include.split(',') - authorized).empty?
  end

  def running_params
    filters = [ 'running' ]
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

  def find_entries_in_current_week_or_month
    entries = Entry.stopped.includes(:project, :user)
    entries = entries.in_current_month if current_month?
    entries = entries.in_current_week if current_week?
    entries = entries.where(user_id: filter_user_id) if filter_user_id
    entries
  end
end
