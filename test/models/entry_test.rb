require 'test_helper'

describe Entry do
  let(:user) { create_user(name: 'louis') }
  subject { build_entry(user: user) }

  it 'is valid' do
    assert subject.valid?
  end
  it 'needs a user' do
    subject.user = nil
    refute subject.valid?
  end
  it 'needs a started at' do
    subject.started_at = nil
    refute subject.valid?
  end
  it 'stopped at is optional' do
    subject.stopped_at = nil
    assert subject.valid?
  end
  it 'stopped at is after started at' do
    subject.stopped_at = subject.started_at - 1.second
    refute subject.valid?
  end
  it 'entry without stopped at is uniq per user' do
    other = create_entry(user: user, stopped_at: nil)
    subject.stopped_at = nil
    refute subject.valid?
  end
  it 'drop the milliseconds on started at' do
    subject.started_at = Time.zone.parse("2016-12-07T09:42:04.123Z")
    assert_equal "2016-12-07T09:42:04.000Z", subject.started_at.utc.as_json
  end
  it 'drop the milliseconds on stopped at' do
    subject.stopped_at = Time.zone.parse("2016-12-07T09:42:04.123Z")
    assert_equal "2016-12-07T09:42:04.000Z", subject.stopped_at.utc.as_json
  end

  it 'duration is in seconds' do
    started_at = Time.zone.now
    duration = 6.hours + 3.minutes + 15.seconds
    stopped_at = started_at + duration
    subject = build_entry(started_at: started_at, stopped_at: stopped_at)
    assert_equal 21795.seconds, subject.duration
  end
  it 'duration is nil without stopped at' do
    subject.stopped_at = nil
    assert_nil subject.duration
  end

  it 'rounded started at is rounded to 5 minutes' do
    assert_equal parse_time("28/06/2018 15:25:00"), build_entry_with_times("28/06/2018 15:25:00", "28/06/2018 16:25:00").rounded_started_at
    assert_equal parse_time("28/06/2018 15:25:00"), build_entry_with_times("28/06/2018 15:25:59", "28/06/2018 16:26:00").rounded_started_at
    assert_equal parse_time("28/06/2018 15:30:00"), build_entry_with_times("28/06/2018 15:26:00", "28/06/2018 16:26:00").rounded_started_at
    assert_equal parse_time("28/06/2018 15:30:00"), build_entry_with_times("28/06/2018 15:29:59", "28/06/2018 16:26:00").rounded_started_at
  end
  it 'rounded duration is rounded to 5 minutes' do
    assert_equal 0.minutes, build_entry_with_times("28/06/2018 15:25:00", "28/06/2018 15:25:59").rounded_duration
    assert_equal 5.minutes, build_entry_with_times("28/06/2018 15:25:00", "28/06/2018 15:26:00").rounded_duration
    assert_equal 5.minutes, build_entry_with_times("28/06/2018 15:25:00", "28/06/2018 15:29:59").rounded_duration
    assert_equal 5.minutes, build_entry_with_times("28/06/2018 15:25:00", "28/06/2018 15:30:00").rounded_duration
  end
  it 'rounded stopped at is rounded to 5 minutes according to started at rounded and duration' do
    assert_equal parse_time("28/06/2018 16:25:00"), build_entry_with_times("28/06/2018 15:25:00", "28/06/2018 16:25:00").rounded_stopped_at
    assert_equal parse_time("28/06/2018 16:25:00"), build_entry_with_times("28/06/2018 15:25:00", "28/06/2018 16:25:59").rounded_stopped_at
    assert_equal parse_time("28/06/2018 16:30:00"), build_entry_with_times("28/06/2018 15:26:00", "28/06/2018 16:26:00").rounded_stopped_at
    assert_equal parse_time("28/06/2018 16:30:00"), build_entry_with_times("28/06/2018 15:29:59", "28/06/2018 16:26:59").rounded_stopped_at
  end

  describe 'Class methods' do
    subject { Entry }

    describe '#in_current_week' do
      let(:beginning_of_week) { Time.zone.now.to_date.beginning_of_week }

      it 'includes entries from current week' do
        entry = create_entry(user: create_user(name: 'louis'), started_at: beginning_of_week + 2.minutes, stopped_at: beginning_of_week + 4.minutes)
        subject.in_current_week.must_include entry
      end
      it 'does not include entries from previous weeks' do
        entry = create_entry(user: create_user(name: 'louis'), started_at: beginning_of_week - 4.minutes, stopped_at: beginning_of_week - 2.minutes)
        subject.in_current_week.wont_include entry
      end
    end

    describe '#filters' do
      it 'includes entries without project with project_ids nil' do
        louis = create_user(name: 'louis')
        entry = create_entry(user: louis)
        subject.filter(
          since: entry.created_at.beginning_of_day,
          before: entry.created_at.end_of_day,
          user_ids: [ louis.id.to_s ],
          project_ids: [nil]
        ).must_include entry
      end
      it 'does not include entries without project without project_ids nil' do
        louis = create_user(name: 'louis')
        entry = create_entry(user: louis, project: create_project(name: 'Tactic'))
        subject.filter(
          since: entry.created_at.beginning_of_day,
          before: entry.created_at.end_of_day,
          user_ids: [ louis.id.to_s ],
          project_ids: [nil]
        ).wont_include entry
      end
      it 'includes entries matching query' do
        user = create_user(name: 'louis')
        since = Time.zone.now.beginning_of_day
        before = Time.zone.now.end_of_day
        entries = [
          create_entry(user: user, title: "tâch", started_at: since + 1.second, stopped_at: since + 2.seconds),
          create_entry(user: user, title: "tâche", started_at: since + 1.second, stopped_at: since + 2.seconds),
          create_entry(user: user, title: "ttâche", started_at: since + 1.second, stopped_at: since + 2.seconds),
          create_entry(user: user, title: "avant tâche", started_at: since + 1.second, stopped_at: since + 2.seconds),
          create_entry(user: user, title: "tâche après", started_at: since + 1.second, stopped_at: since + 2.seconds),
          create_entry(user: user, title: "avant tâche après", started_at: since + 1.second, stopped_at: since + 2.seconds)
        ]
        (entries - subject.filter(since: since, before: before, query: "tâch")).must_be_empty
      end
      it 'does not include entries not matching query' do
        user = create_user(name: 'louis')
        since = Time.zone.now.beginning_of_day
        before = Time.zone.now.end_of_day
        create_entry(user: user, title: "un truc qui n'a rien à voir", started_at: since + 1.second, stopped_at: since + 2.seconds)
        create_entry(user: user, title: "tâc", started_at: since + 1.second, stopped_at: since + 2.seconds)
        subject.filter(since: since, before: before, query: "tâch").must_be_empty
      end
      it 'includes entries matching OR query' do
        user = create_user(name: 'louis')
        since = Time.zone.now.beginning_of_day
        before = Time.zone.now.end_of_day
        entries = [
          create_entry(user: user, title: "une tâche", started_at: since + 1.second, stopped_at: since + 2.seconds),
          create_entry(user: user, title: "à faire", started_at: since + 1.second, stopped_at: since + 2.seconds),
          create_entry(user: user, title: "une tâche à faire", started_at: since + 1.second, stopped_at: since + 2.seconds)
        ]
        (entries - subject.filter(since: since, before: before, query: "tâche | faire")).must_be_empty
      end
      it 'does not include entries not matching OR query' do
        user = create_user(name: 'louis')
        since = Time.zone.now.beginning_of_day
        before = Time.zone.now.end_of_day
        create_entry(user: user, title: "un truc qui n'a rien à voir", started_at: since + 1.second, stopped_at: since + 2.seconds)
        create_entry(user: user, title: "tâc", started_at: since + 1.second, stopped_at: since + 2.seconds)
        subject.filter(since: since, before: before, query: "tâche | faire").must_be_empty
      end
      it 'includes entries matching AND query' do
        user = create_user(name: 'louis')
        since = Time.zone.now.beginning_of_day
        before = Time.zone.now.end_of_day
        entries = [
          create_entry(user: user, title: "une tâche qu'il faut faire", started_at: since + 1.second, stopped_at: since + 2.seconds)
        ]
        (entries - subject.filter(since: since, before: before, query: "qu'il faut faire")).must_be_empty
      end
      it 'does not include entries not matching OR query' do
        user = create_user(name: 'louis')
        since = Time.zone.now.beginning_of_day
        before = Time.zone.now.end_of_day
        create_entry(user: user, title: "une tâche", started_at: since + 1.second, stopped_at: since + 2.seconds)
        create_entry(user: user, title: "il faut", started_at: since + 1.second, stopped_at: since + 2.seconds)
        create_entry(user: user, title: "une tâche qu'il faut", started_at: since + 1.second, stopped_at: since + 2.seconds)
        create_entry(user: user, title: "faut faire", started_at: since + 1.second, stopped_at: since + 2.seconds)
        subject.filter(since: since, before: before, query: "qu'il faut faire").must_be_empty
      end
    end
  end

  def build_entry_with_times(started_at, stopped_at)
    build_entry(
      user: user,
      started_at: parse_time(started_at),
      stopped_at: parse_time(stopped_at)
    )
  end

  def parse_time(time)
    Time.zone.parse time
  end
end
