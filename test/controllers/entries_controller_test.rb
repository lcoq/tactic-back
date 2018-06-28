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
    it 'does not serialize running entry' do
      entry = create_entry(user: user, stopped_at: nil)
      get '/entries', headers: headers
      assert_response :success
      assert_equal serialized([], EntrySerializer), response.body
    end
    it 'includes projects' do
      project = create_project(name: 'Tactic')
      entries = [create_entry(user: user, project: project)]
      get '/entries', headers: headers, params: { 'include' => 'project' }
      assert_response :success
      assert_equal serialized(entries, EntrySerializer, include: 'project'), response.body
    end
    describe 'With current-week filter' do
      let(:params) do
        { 'filter' => { 'current-week' => '1' } }
      end
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
        get '/entries', headers: headers, params: params
        assert_response :success
        assert_equal serialized(current_week_entries, EntrySerializer), response.body
      end
      it 'does not serialize running entry' do
        entry = create_entry(user: user, stopped_at: nil)
        get '/entries', headers: headers, params: params
        assert_response :success
        assert_equal serialized([], EntrySerializer), response.body
      end
    end
    describe 'With current-week and user-id filter' do
      let(:params) do
        { 'filter' => { 'current-week' => '1', 'user-id' => [user.id.to_s] } }
      end
      it 'serialize current week entries' do
        other_user = create_user(name: 'adrien')
        current_week_user_entries = [
          create_entry(user: user, started_at: Time.zone.now - 2.minutes, stopped_at: Time.zone.now),
          create_entry(user: user, started_at: Time.zone.now - 2.minutes, stopped_at: Time.zone.now)
        ]
        other_entries = [
          create_entry(user: other_user, started_at: Time.zone.now - 2.minutes, stopped_at: Time.zone.now),
          create_entry(user: user, started_at: Time.zone.now - 1.week - 1.hour, stopped_at: Time.zone.now - 1.week),
          create_entry(user: other_user, started_at: Time.zone.now - 1.week - 1.hour, stopped_at: Time.zone.now - 1.week)
        ]
        get '/entries', headers: headers, params: params
        assert_response :success
        assert_equal serialized(current_week_user_entries, EntrySerializer), response.body
      end
    end
    describe 'With current-month and user-id filter' do
      let(:params) do
        { 'filter' => { 'current-month' => '1', 'user-id' => [user.id.to_s] } }
      end
      it 'serialize current month entries' do
        other_user = create_user(name: 'adrien')
        current_month_user_entries = [
          create_entry(user: user, started_at: Time.zone.now - 20.minutes, stopped_at: Time.zone.now),
          create_entry(user: user, started_at: Time.zone.now - 2.hours, stopped_at: Time.zone.now)
          # TODO create entry with started_at older than 1 week but less than 1 month
        ]
        other_entries = [
          create_entry(user: other_user, started_at: Time.zone.now - 2.minutes, stopped_at: Time.zone.now),
          create_entry(user: user, started_at: Time.zone.now - 1.month - 1.hour, stopped_at: Time.zone.now - 1.month),
          create_entry(user: other_user, started_at: Time.zone.now - 1.month - 1.hour, stopped_at: Time.zone.now - 1.month)
        ]
        get '/entries', headers: headers, params: params
        assert_response :success
        assert_equal serialized(current_month_user_entries, EntrySerializer), response.body
      end
    end
    describe 'With user-id, project-id, started-at and stopped-at filters' do
      it 'serialize entries filtered' do
        adrien = create_user(name: 'adrien')
        tactic = create_project(name: 'tactic')
        tictoc = create_project(name: 'tictoc')
        other_project = create_project(name: 'other')

        filtered_entries = [
          create_entry(user: adrien, started_at: Time.zone.now - 3.hours, stopped_at: Time.zone.now - 2.hours, project: tactic),
          create_entry(user: adrien, started_at: Time.zone.now - 10.minutes, stopped_at: Time.zone.now, project: tactic),
          create_entry(user: adrien, started_at: Time.zone.now - 2.hours, stopped_at: Time.zone.now - 1.hour, project: tictoc)
        ]

        other_entries = [
          create_entry(user: user, started_at: Time.zone.now - 3.hours, stopped_at: Time.zone.now - 2.hours, project: tactic),
          create_entry(user: adrien, started_at: Time.zone.now - 3.hours, stopped_at: Time.zone.now - 2.hours, project: other_project),
          create_entry(user: adrien, started_at: Time.zone.now - 3.days - 2.hours, stopped_at: Time.zone.now - 3.days - 1.hour, project: other_project)
        ]

        filters = {
          'user-id' => [ adrien.id.to_s ],
          'project-id' => [ tactic.id.to_s, tictoc.id.to_s ],
          'since' => (Time.zone.now - 1.day).beginning_of_day.as_json,
          'before' => Time.zone.now.end_of_day.as_json
        }
        get '/entries', headers: headers, params: { 'filter' => filters }
        assert_response :success
        assert_equal serialized(filtered_entries, EntrySerializer), response.body
      end
      it 'does not serialize running entries' do
        adrien = create_user(name: 'adrien')
        tactic = create_project(name: 'tactic')
        create_entry(user: adrien, started_at: Time.zone.now - 1.minute, stopped_at: nil, project: tactic)

        filters = {
          'user-id' => [ adrien.id.to_s ],
          'project-id' => [ tactic.id.to_s ],
          'since' => (Time.zone.now - 1.day).beginning_of_day.as_json,
          'before' => Time.zone.now.end_of_day.as_json
        }
        get '/entries', headers: headers, params: { 'filter' => filters }
        assert_response :success
        assert_equal serialized([], EntrySerializer), response.body
      end
    end
    describe 'With query filter' do
      let(:params) do
        {
          'filter' => {
            'since' => '1970-01-01T22:00:00.000Z',
            'before' => (Time.zone.now + 10.years).to_s,
            'query' => 'tâch'
          }
        }
      end
      it 'serialize matching entries' do
        entries = [
          create_entry(user: user, title: "tâch"),
          create_entry(user: user, title: "tâche"),
          create_entry(user: user, title: "ttâche"),
          create_entry(user: user, title: "avant tâche"),
          create_entry(user: user, title: "tâche après"),
          create_entry(user: user, title: "avant tâche après")
        ]
        get '/entries', headers: headers, params: params
        assert_response :success
        assert_equal serialized(entries, EntrySerializer), response.body
      end
      it 'does not serialize non matching entries' do
        create_entry(user: user, title: "un truc qui n'a rien à voir")
        create_entry(user: user, title: "tâc")
        get '/entries', headers: headers, params: params
        assert_response :success
        assert_equal serialized([], EntrySerializer), response.body
      end
    end
    describe 'With csv format' do
      it 'serialize entries filtered' do
        adrien = create_user(name: 'adrien')
        tactic = create_project(name: 'tactic')
        tictoc = create_project(name: 'tictoc')
        other_project = create_project(name: 'other')

        filtered_entries = [
          create_entry(user: adrien, started_at: Time.zone.now - 3.hours, stopped_at: Time.zone.now - 2.hours, project: tactic),
          create_entry(user: adrien, started_at: Time.zone.now - 10.minutes, stopped_at: Time.zone.now, project: tactic),
          create_entry(user: adrien, started_at: Time.zone.now - 2.hours, stopped_at: Time.zone.now - 1.hour, project: tictoc)
        ]

        other_entries = [
          create_entry(user: user, started_at: Time.zone.now - 3.hours, stopped_at: Time.zone.now - 2.hours, project: tactic),
          create_entry(user: adrien, started_at: Time.zone.now - 3.hours, stopped_at: Time.zone.now - 2.hours, project: other_project),
          create_entry(user: adrien, started_at: Time.zone.now - 3.days - 2.hours, stopped_at: Time.zone.now - 3.days - 1.hour, project: other_project)
        ]

        filters = {
          'user-id' => [ adrien.id.to_s ],
          'project-id' => [ tactic.id.to_s, tictoc.id.to_s ],
          'since' => (Time.zone.now - 1.day).beginning_of_day.as_json,
          'before' => Time.zone.now.end_of_day.as_json
        }
        get '/entries.csv', params: { 'filter' => filters, 'Authorization' => headers['Authorization'] }
        assert_response :success
        csv = CSV.parse(response.body, headers: true)
        assert_equal filtered_entries.length, csv.length
      end
      it 'serialize entries filtered and rounded' do
        now = Time.zone.now.beginning_of_hour
        create_entry(user: user, started_at: (now + 25.minutes + 59.seconds), stopped_at: (now + 30.minutes + 1.second))
        create_entry(user: user, started_at: (now + 10.minutes + 00.seconds), stopped_at: (now + 10.minutes + 59.second))
        filters = {
          'user-id' => [ user.id.to_s ],
          'project-id' => ['0'],
          'since' => (Time.zone.now - 1.day).beginning_of_day.as_json,
          'before' => Time.zone.now.end_of_day.as_json
        }
        options = {
          'rounded' => true
        }
        get '/entries.csv', params: { 'filter' => filters, 'options' => options, 'Authorization' => headers['Authorization'] }
        assert_response :success
        csv = CSV.parse(response.body, headers: true)
        assert_equal '00:05', csv[0]['duration']
        assert_equal '00:00', csv[1]['duration']
      end
      it 'sort entries by user, client, project name and started at desc' do
        adrien = create_user(name: 'adrien')
        ingrid = create_user(name: 'ingrid')

        efficiency = create_client(name: 'efficiency')
        productivity = create_client(name: 'productivity')

        no_client_project = create_project(name: 'no client')

        tactic = create_project(name: 'tactic', client: efficiency)
        tictoc = create_project(name: 'tictoc', client: efficiency)

        tuctuc = create_project(name: 'tuctuc', client: productivity)
        tyctyc = create_project(name: 'tyctyc', client: productivity)

        entries = [
          create_entry(title: 'e1', user: adrien, started_at: Time.zone.now - 5.hours, stopped_at: Time.zone.now - 4.hours, project: nil),

          create_entry(title: 'e2', user: adrien, started_at: Time.zone.now - 6.hours, stopped_at: Time.zone.now - 5.hours, project: no_client_project),

          create_entry(title: 'e3', user: adrien, started_at: Time.zone.now - 6.hours, stopped_at: Time.zone.now - 5.hours, project: tactic),
          create_entry(title: 'e4', user: adrien, started_at: Time.zone.now - 7.hours, stopped_at: Time.zone.now - 6.hours, project: tactic),

          create_entry(title: 'e5', user: adrien, started_at: Time.zone.now - 8.hours, stopped_at: Time.zone.now - 7.hours, project: tictoc),

          create_entry(title: 'e6', user: adrien, started_at: Time.zone.now - 2.hours, stopped_at: Time.zone.now - 1.hours, project: tuctuc),
          create_entry(title: 'e7', user: adrien, started_at: Time.zone.now - 3.hours, stopped_at: Time.zone.now - 2.hours, project: tuctuc),

          create_entry(title: 'e8', user: adrien, started_at: Time.zone.now - 2.hours, stopped_at: Time.zone.now - 1.hours, project: tyctyc),

          create_entry(title: 'e9', user: ingrid, started_at: Time.zone.now - 1.hours, stopped_at: Time.zone.now, project: nil),
          create_entry(title: 'e10', user: ingrid, started_at: Time.zone.now - 2.hours, stopped_at: Time.zone.now, project: nil),

          create_entry(title: 'e11', user: ingrid, started_at: Time.zone.now - 2.hours, stopped_at: Time.zone.now, project: tuctuc)
        ]

        filters = {
          'user-id' => [ adrien.id.to_s, ingrid.id.to_s ],
          'project-id' => [ '0', no_client_project.id.to_s , tactic.id.to_s, tictoc.id.to_s, tuctuc.id.to_s, tyctyc.id.to_s ],
          'since' => (Time.zone.now - 1.day).beginning_of_day.as_json,
          'before' => Time.zone.now.end_of_day.as_json
        }
        get '/entries.csv', params: { 'filter' => filters, 'Authorization' => headers['Authorization'] }
        assert_response :success
        csv_titles = CSV.parse(response.body, headers: true).map { |row| row['title'] }
        assert_equal entries.map(&:title), csv_titles
      end
      it 'does not serialize running entries' do
        adrien = create_user(name: 'adrien')
        tactic = create_project(name: 'tactic')
        create_entry(user: adrien, started_at: Time.zone.now - 1.minute, stopped_at: nil, project: tactic)

        filters = {
          'user-id' => [ adrien.id.to_s ],
          'project-id' => [ tactic.id.to_s ],
          'since' => (Time.zone.now - 1.day).beginning_of_day.as_json,
          'before' => Time.zone.now.end_of_day.as_json
        }
        get '/entries.csv', params: { 'filter' => filters, 'Authorization' => headers['Authorization'] }
        assert_response :success
        csv = CSV.parse(response.body, headers: true)
        assert_equal 0, csv.length
      end
    end
  end

  describe '#running' do
    let(:params) do
      { 'filter' => { 'running' => '1' } }
    end
    it 'is forbidden with invalid Authorization header' do
      get '/entries', headers: { 'Authorization' => 'invalid' }, params: params
      assert_response :forbidden
    end
    it 'serialize nil data when the current user has no running entry' do
      get '/entries', headers: headers, params: params
      assert_response :success
      assert_equal({ 'data' => nil }, JSON.parse(response.body))
    end
    it 'serialize the current user running entry' do
      entry = create_entry(user: user, stopped_at: nil)
      get '/entries', headers: headers, params: params
      assert_response :success
      assert_equal serialized(entry, EntrySerializer), response.body
    end
    it 'includes project' do
      entry = create_entry(user: user, project: create_project(name: 'tactic'), stopped_at: nil)
      params['include'] = 'project'
      get '/entries', headers: headers, params: params
      assert_response :success
      assert_equal serialized(entry, EntrySerializer, include: 'project'), response.body
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
