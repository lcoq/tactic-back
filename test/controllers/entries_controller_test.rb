require 'test_helper'

describe EntriesController do
  let(:user) { create_user(name: 'louis') }
  let(:session) { build_session(user: user).tap { |s| assert s.save } }
  let(:headers) { { 'Authorization' => session.token } }

  describe '#index' do
    it 'is forbidden with invalid Authorization header' do
      get '/entries', headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'serialize recent user entries' do
      oldest_entries = 5.times.map do
        create_entry(user: user).tap do |e|
          started_at = Time.zone.now - 3.months
          e.update_columns(started_at: started_at, stopped_at: started_at + 10.minutes)
        end
      end
      entries = 20.times.map { create_entry(user: user) }
      get '/entries', headers: headers
      assert_response :success
      assert_equal serialized(entries, EntrySerializer), response.body
    end
    it 'includes projects' do
      project = create_project(name: 'Tactic')
      entries = [create_entry(user: user, project: project)]
      get '/entries', headers: headers, params: { 'include' => 'project' }
      assert_response :success
      assert_equal serialized(entries, EntrySerializer, include: 'project'), response.body
    end
    describe 'With current-week filter' do
      it 'serialize current week entries' do
        other_user = create_user(name: 'adrien')
        current_week_entries = [
          create_entry(user: user, started_at: Time.zone.now - 2.minutes, stopped_at: Time.zone.now),
          create_entry(user: other_user, started_at: Time.zone.now - 2.minutes, stopped_at: Time.zone.now),
          create_entry(user: other_user, started_at: Time.zone.now - 2.minutes, stopped_at: Time.zone.now)
        ]
        other_entries = [
          create_entry(user: user, started_at: Time.zone.now - 1.week - 1.hour, stopped_at: Time.zone.now - 1.week),
          create_entry(user: other_user, started_at: Time.zone.now - 1.week - 1.hour, stopped_at: Time.zone.now - 1.week)
        ]
        get '/entries', headers: headers, params: { 'filter' => { 'current-week' => '1' } }
        assert_response :success
        assert_equal serialized(current_week_entries, EntrySerializer), response.body
      end
    end
  end

  describe '#create' do
    let(:project) { create_project(name: 'tictoc') }
    let(:params) do
      {
        'data' => {
          'type' => 'entries',
          'attributes' => {
            'title' => 'new entry',
            'started-at' => "2016-12-07T09:42:04.017Z",
            'stopped-at' => "2016-12-07T09:48:00.017Z"
          },
          'relationships' => {
            'project' => {
              'data' => {
                'type' => 'projects',
                'id' => project.id.to_s
              }
            }
          }
        }
      }
    end

    it 'is forbidden with invalid Authorization header' do
      post "/entries", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'create the entry assigned to the current user' do
      post "/entries", headers: headers, params: params
      assert_response :success
      entry = Entry.find_by(title: 'new entry')
      assert entry
      assert_equal DateTime.parse("2016-12-07T09:42:04.017Z").to_i, entry.started_at.to_i
      assert_equal DateTime.parse("2016-12-07T09:48:00.017Z").to_i, entry.stopped_at.to_i
      assert_equal project, entry.project
      assert_equal user, entry.user
   end
    it 'serialize the entry' do
      post "/entries", headers: headers, params: params
      assert_response :success
      entry = Entry.find_by(title: 'new entry')
      assert_equal serialized(entry, EntrySerializer), response.body
    end
    describe 'With invalid params' do
      before do
        params['data']['attributes']['started-at'] = nil
      end
      it 'does not create the entry' do
        post "/entries", headers: headers, params: params
        assert_response :unprocessable_entity
      end
      it 'serialize the errors' do
        post "/entries", headers: headers, params: params
        assert_response :unprocessable_entity
        parsed = JSON.parse(response.body)
        parsed['errors'].wont_be_empty
        assert parsed['errors'].any? { | error| error['source']['pointer'] == '/data/attributes/started-at' }
      end
    end
  end

  describe '#update' do
    let(:entry) { create_entry(user: user, title: 'initial entry title') }
    let(:params) do
      {
        'data' => {
          'type' => 'entries',
          'attributes' => {
            'title' => 'updated-title',
            'started-at' => "2016-12-07T09:42:04.017Z",
            'stopped-at' => "2016-12-07T09:48:00.017Z"
          },
          'relationships' => {
            'project' => {
              'data' => {
                'type' => 'projects',
                'id' => create_project(name: 'Tictoc').id.to_s
              }
            },
            'user' => {
              'data' => {
                'type' => 'users',
                'id' => user.id.to_s
              }
            }
          }
        }
      }
    end

    it 'is forbidden with invalid Authorization header' do
      patch "/entries/#{entry.id}", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'update the entry' do
      patch "/entries/#{entry.id}", headers: headers, params: params
      assert_response :success
      entry.reload
      assert_equal 'updated-title', entry.title
      assert_equal Time.zone.parse("2016-12-07T09:42:04.017Z").to_i, entry.started_at.to_i
      assert_equal Time.zone.parse("2016-12-07T09:48:00.017Z").to_i, entry.stopped_at.to_i
      assert_equal "Tictoc", entry.project.name
    end
    it 'serialize the entry' do
      patch "/entries/#{entry.id}", headers: headers, params: params
      assert_response :success
      assert_equal serialized(entry.reload, EntrySerializer), response.body
    end
    describe 'With invalid params' do
      before do
        params['data']['attributes']['started-at'] = nil
      end
      it 'does not update the entry' do
        patch "/entries/#{entry.id}", headers: headers, params: params
        assert_response :unprocessable_entity
        entry.reload
        assert_equal 'initial entry title', entry.title
      end
      it 'serialize the errors' do
        patch "/entries/#{entry.id}", headers: headers, params: params
        assert_response :unprocessable_entity
        parsed = JSON.parse(response.body)
        parsed['errors'].wont_be_empty
        assert parsed['errors'].any? { | error| error['source']['pointer'] == '/data/attributes/started-at' }
      end
    end
  end

  describe '#destroy' do
    let(:entry) { create_entry(user: user) }

    it 'is forbidden with invalid Authorization header' do
      delete "/entries/#{entry.id}", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'destroy the entry' do
      delete "/entries/#{entry.id}", headers: headers
      assert_response :success
      assert_raises(ActiveRecord::RecordNotFound) { entry.reload }
    end
    it 'serialize the entry' do
      delete "/entries/#{entry.id}", headers: headers
      assert_response :success
      assert_equal serialized(entry, EntrySerializer), response.body
    end
  end
end
