require 'test_helper'

describe EntriesStatGroupBuilder do
  subject { EntriesStatGroupBuilder.new }
  let(:user) { create_user(name: 'louis') }
  let(:other_user) { create_user(name: 'adrien') }

  describe '#daily' do
    let(:today) { Time.zone.now.to_date }
    let(:before) { (today - 2.days).end_of_day }
    let(:since) { (today - 7.days).beginning_of_day }
    let(:filters) { { before: before, since: since } }

    let(:included_range) { (since.to_time..before.to_time) }
    let(:included_entries) do
      5.times.map do
        started_at, stopped_at = 2.times.map { rand(included_range) }.sort
        create_entry(user: user, started_at: started_at, stopped_at: stopped_at)
      end +
        2.times.map do
        started_at, stopped_at = 2.times.map { rand(included_range) }.sort
        create_entry(user: other_user, started_at: started_at, stopped_at: stopped_at)
      end
    end

    let(:excluded_before_range) { ((since.to_time - 3.days)...since.to_time) }
    let(:excluded_before_entries) do
      6.times.map do
        started_at, stopped_at = 2.times.map { rand(excluded_before_range) }.sort
        create_entry(user: user, started_at: started_at, stopped_at: stopped_at)
      end
    end
    let(:excluded_after_range) { ((before.to_time + 1.second)..(before.to_time + 3.days)) }
    let(:excluded_after_entries) do
      6.times.map do
        started_at, stopped_at = 2.times.map { rand(excluded_after_range) }.sort
        create_entry(user: user, started_at: started_at, stopped_at: stopped_at)
      end
    end

    it 'is an entries stat group' do
      group = subject.daily(filters)
      assert_equal EntriesStatGroup, group.class
    end

    it 'has id' do
      expected_format = "%Y/%m/%d"
      expected_id = "#{since.strftime(expected_format)}-#{before.strftime(expected_format)}"
      group = subject.daily(filters)
      assert_equal expected_id, group.id
    end

    it 'has title' do
      expected_format = "%-d %B %Y"
      expected_title = "Hours per day from #{since.strftime(expected_format)} to #{before.strftime(expected_format)}"
      group = subject.daily(filters)
      assert_equal expected_title, group.title
    end

    it 'has nature' do
      group = subject.daily(filters)
      assert_equal 'hour/day', group.nature
    end

    it 'entries stats are all in given range' do
      context = [ included_entries, excluded_before_entries, excluded_after_entries ]
      group = subject.daily(filters)
      assert group.entries_stats.any?
      group.entries_stats.each do |stat|
        assert_includes included_range, stat.date
      end
    end

    it 'entries stats duration matches entries in given range'do
      context = [ included_entries, excluded_before_entries, excluded_after_entries ]
      group = subject.daily(filters)
      assert_equal included_entries.sum(&:duration), group.entries_stats.sum(&:duration)
    end

    it 'has one entry stat per day' do
      context = [ included_entries, excluded_before_entries, excluded_after_entries ]
      group = subject.daily(filters)
      expected_days = included_entries.each_with_object(Set.new) do |entry, set|
        set.add entry.started_at.to_date
      end
      assert_equal expected_days.length, group.entries_stats.length
      group.entries_stats.each do |stat|
        assert_includes expected_days, stat.date
      end
    end

    it 'entries stats have id that matches the date' do
      context = [ included_entries, excluded_before_entries, excluded_after_entries ]
      group = subject.daily(filters)
      assert group.entries_stats.all? { |stat| stat.id == stat.date.to_s }
    end

    it 'computes entries stats with the right time zone' do
      create_entry(
        user: user,
        started_at: Time.zone.parse('2022-03-12 00:01:50 +0100'),
        stopped_at: Time.zone.parse('2022-03-12 00:06:55 +0100')
      )
      group = subject.daily(
        since: Time.zone.parse("2022-03-11T23:00:00.000Z"),
        before: Time.zone.parse("2022-03-12T22:59:59.999Z"),
      )
      assert_equal 1, group.entries_stats.length
      assert_equal Date.parse('2022-03-12'), group.entries_stats[0].date
    end
  end

  describe '#monthly' do
    let(:today) { Time.zone.now.to_date }
    let(:before) { (today - 3.months).end_of_month }
    let(:since) { (today - 7.months).beginning_of_month }
    let(:filters) { { before: before, since: since } }

    let(:included_range) { (since.to_time..before.to_time) }
    let(:included_entries) do
      5.times.map do
        started_at = rand(included_range)
        stopped_at = started_at + (rand(30) + 1).minutes
        create_entry(user: user, started_at: started_at, stopped_at: stopped_at)
      end +
        2.times.map do
        started_at = rand(included_range)
        stopped_at = started_at + (rand(30) + 1).minutes
        create_entry(user: other_user, started_at: started_at, stopped_at: stopped_at)
      end
    end

    let(:excluded_before_range) { ((since.to_time - 3.days)...since.to_time) }
    let(:excluded_before_entries) do
      6.times.map do
        started_at, stopped_at = 2.times.map { rand(excluded_before_range) }.sort
        create_entry(user: user, started_at: started_at, stopped_at: stopped_at)
      end
    end
    let(:excluded_after_range) { ((before.to_time + 1.second)..(before.to_time + 3.days)) }
    let(:excluded_after_entries) do
      6.times.map do
        started_at, stopped_at = 2.times.map { rand(excluded_after_range) }.sort
        create_entry(user: user, started_at: started_at, stopped_at: stopped_at)
      end
    end

    it 'is an entries stat group' do
      group = subject.monthly(filters)
      assert_equal EntriesStatGroup, group.class
    end

    it 'has id' do
      expected_format = "%Y/%m"
      expected_id = "#{since.strftime(expected_format)}-#{before.strftime(expected_format)}"
      group = subject.monthly(filters)
      assert_equal expected_id, group.id
    end

    it 'has title' do
      expected_format = "%-d %B %Y"
      expected_title = "Hours per month from #{since.strftime(expected_format)} to #{before.strftime(expected_format)}"
      group = subject.monthly(filters)
      assert_equal expected_title, group.title
    end

    it 'has nature' do
      group = subject.monthly(filters)
      assert_equal 'hour/month', group.nature
    end

    it 'entries stats are all in given range' do
      context = [ included_entries, excluded_before_entries, excluded_after_entries ]
      group = subject.monthly(filters)
      assert group.entries_stats.any?
      group.entries_stats.each do |stat|
        assert_includes included_range, stat.date
      end
    end

    it 'entries stats duration matches entries in given range'do
      context = [ included_entries, excluded_before_entries, excluded_after_entries ]
      group = subject.monthly(filters)
      assert_equal included_entries.sum(&:duration), group.entries_stats.sum(&:duration)
    end

    it 'has one entry stat per month' do
      context = [ included_entries, excluded_before_entries, excluded_after_entries ]
      group = subject.monthly(filters)
      expected_months = included_entries.each_with_object(Set.new) do |entry, set|
        set.add entry.started_at.beginning_of_month.to_date
      end
      assert_equal expected_months.length, group.entries_stats.length
      group.entries_stats.each do |stat|
        assert_includes expected_months, stat.date
      end
    end

    it 'entries stats have id that matches the date' do
      context = [ included_entries, excluded_before_entries, excluded_after_entries ]
      group = subject.monthly(filters)
      assert group.entries_stats.all? { |stat| stat.id == stat.date.to_s }
    end
  end


end
