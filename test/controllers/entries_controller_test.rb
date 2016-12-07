require 'test_helper'

describe EntriesController do
  describe '#index' do
    let(:user) { create_user(name: 'louis') }
    let(:session) { build_session(user: user).tap { |s| assert s.save } }
    let(:headers) { { 'Authorization' => session.token } }

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
end
