require 'test_helper'

describe EntriesStatGroupsController do
  let(:user) { create_user(name: 'louis') }
  let(:session) { build_session(user: user).tap { |s| assert s.save } }
  let(:headers) { { 'Authorization' => session.token } }

  describe '#daily' do
    let(:path) { '/stats/daily' }

    it 'is forbidden with invalid Authorization header' do
      get path, headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'is unprocessable entity without filters' do
      get path, headers: headers
      assert_response :unprocessable_entity
    end
    it 'serializes entry stat group according to filters' do
      adrien = create_user(name: 'adrien')
      tactic = create_project(name: 'tactic')
      tictoc = create_project(name: 'tictoc')
      other_project = create_project(name: 'other')

      filtered_entries = [
        create_entry(user: adrien, started_at: (Time.zone.now - 4.days + 1.hours), stopped_at: (Time.zone.now - 4.days + 2.hours), project: tactic),
        create_entry(user: adrien, started_at: (Time.zone.now - 5.days + 10.minutes), stopped_at: (Time.zone.now - 5.days + 15.minutes), project: tactic),
        create_entry(user: adrien, started_at: (Time.zone.now - 2.days + 20.hours), stopped_at: (Time.zone.now - 2.days + 21.hours), project: tictoc)
      ]

      other_entries = [
        create_entry(user: user, started_at: (Time.zone.now - 4.days + 1.hours), stopped_at: (Time.zone.now - 4.days + 2.hours), project: tactic),
        create_entry(user: adrien, started_at: (Time.zone.now - 4.days + 10.minutes), stopped_at: (Time.zone.now - 4.days + 1.hours), project: other_project),
        create_entry(user: adrien, started_at: (Time.zone.now - 2.days + 2.hours), stopped_at: (Time.zone.now - 2.days + 3.hours), project: other_project),
        create_entry(user: adrien, started_at: (Time.zone.now - 5.days - 2.hours), stopped_at: (Time.zone.now - 5.days - 1.hours), project: tactic),
        create_entry(user: adrien, started_at: (Time.zone.now - 1.day + 1.hour), stopped_at: (Time.zone.now - 1.days + 2.hours), project: tactic),
      ]

      filters = {
        'user-id' => [ adrien.id.to_s ],
        'project-id' => [ tactic.id.to_s, tictoc.id.to_s ],
        'since' => (Time.zone.now - 5.day).beginning_of_day.as_json,
        'before' => (Time.zone.now - 1.day).end_of_day.as_json,
        'query' => 't'
      }

      expected_builder = EntriesStatGroupBuilder.daily(
        user_ids:  filters['user-id'],
        project_ids:  filters['project-id'],
        since: Time.zone.parse(filters['since']),
        before: Time.zone.parse(filters['before']),
        query: 't'
      )

      get path, headers: headers, params: { 'filter' => filters }
      assert_response :success
      assert_equal serialized(expected_builder, EntriesStatGroupSerializer, include: 'entries_stats'), response.body
    end
  end

  describe '#monthly' do
    let(:path) { '/stats/monthly' }

    it 'is forbidden with invalid Authorization header' do
      get path, headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'is unprocessable entity without filters'do
      get path, headers: headers
      assert_response :unprocessable_entity
    end
    it 'serializes entry stat group according to filters' do
      adrien = create_user(name: 'adrien')
      tactic = create_project(name: 'tactic')
      tictoc = create_project(name: 'tictoc')
      other_project = create_project(name: 'other')

      filtered_entries = [
        create_entry(user: adrien, started_at: (Time.zone.now - 4.months + 1.hours), stopped_at: (Time.zone.now - 4.months + 2.hours), project: tactic),
        create_entry(user: adrien, started_at: (Time.zone.now - 5.months + 10.minutes), stopped_at: (Time.zone.now - 5.months + 15.minutes), project: tactic),
        create_entry(user: adrien, started_at: (Time.zone.now - 2.months + 20.hours), stopped_at: (Time.zone.now - 2.months + 21.hours), project: tictoc)
      ]

      other_entries = [
        create_entry(user: user, started_at: (Time.zone.now - 4.months + 1.hours), stopped_at: (Time.zone.now - 4.months + 2.hours), project: tactic),
        create_entry(user: adrien, started_at: (Time.zone.now - 4.months + 10.minutes), stopped_at: (Time.zone.now - 4.months + 1.hours), project: other_project),
        create_entry(user: adrien, started_at: (Time.zone.now - 2.months + 2.hours), stopped_at: (Time.zone.now - 2.months + 3.hours), project: other_project),
        create_entry(user: adrien, started_at: (Time.zone.now - 5.months - 2.hours), stopped_at: (Time.zone.now - 5.months - 1.hours), project: tactic),
        create_entry(user: adrien, started_at: (Time.zone.now - 1.month + 1.hour), stopped_at: (Time.zone.now - 1.months + 2.hours), project: tactic),
      ]

      filters = {
        'user-id' => [ adrien.id.to_s ],
        'project-id' => [ tactic.id.to_s, tictoc.id.to_s ],
        'since' => (Time.zone.now - 5.month).beginning_of_month.as_json,
        'before' => (Time.zone.now - 1.month).end_of_month.as_json,
        'query' => 't'
      }

      expected_builder = EntriesStatGroupBuilder.monthly(
        user_ids:  filters['user-id'],
        project_ids:  filters['project-id'],
        since: Time.zone.parse(filters['since']),
        before: Time.zone.parse(filters['before']),
        query: 't'
      )

      get path, headers: headers, params: { 'filter' => filters }
      assert_response :success
      assert_equal serialized(expected_builder, EntriesStatGroupSerializer, include: 'entries_stats'), response.body
    end
  end

end
