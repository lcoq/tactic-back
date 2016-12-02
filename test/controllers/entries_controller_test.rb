require 'test_helper'

describe EntriesController do
  describe '#index' do
    it 'is forbidden with invalid Authorization header' do
      get '/entries', headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'serialize recent user entries' do
      user = create_user(name: 'louis')
      session = build_session(user: user).tap { |s| assert s.save }
      oldest_entries = 5.times.map do
        create_entry(user: user).tap do |e|
          started_at = Time.zone.now - 3.months
          e.update_columns(started_at: started_at, stopped_at: started_at + 10.minutes)
        end
      end
      entries = 20.times.map { create_entry(user: user) }
      get '/entries', headers: { 'Authorization' => session.token }
      assert_response :success
      assert_equal serialized(entries, EntrySerializer), response.body
    end
    it 'includes projects' do
      user = create_user(name: 'louis')
      session = build_session(user: user).tap { |s| assert s.save }
      project = create_project(name: 'Tactic')
      entries = [create_entry(user: user, project: project)]
      get '/entries', headers: { 'Authorization' => session.token }, params: { 'include' => 'project' }
      assert_response :success
      assert_equal serialized(entries, EntrySerializer, include: 'project'), response.body
    end
  end
end
