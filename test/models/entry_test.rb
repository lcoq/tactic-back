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
  it 'needs a stopped at' do
    subject.stopped_at = nil
    refute subject.valid?
  end
  it 'stopped at is after started at' do
    subject.stopped_at = subject.started_at - 1.second
    refute subject.valid?
  end
  it 'drop the milliseconds on started at' do
    subject.started_at = Time.zone.parse("2016-12-07T09:42:04.123Z")
    assert_equal "2016-12-07T09:42:04.000Z", subject.started_at.as_json
  end
  it 'drop the milliseconds on stopped at' do
    subject.stopped_at = Time.zone.parse("2016-12-07T09:42:04.123Z")
    assert_equal "2016-12-07T09:42:04.000Z", subject.stopped_at.as_json
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
      it 'includes entries without project with project_ids 0' do
        louis = create_user(name: 'louis')
        entry = create_entry(user: louis)
        subject.filter(
          since: entry.created_at.beginning_of_day,
          before: entry.created_at.end_of_day,
          user_ids: [ louis.id.to_s ],
          project_ids: ['0']
        ).must_include entry
      end
      it 'does not include entries without project without project_ids 0' do
        louis = create_user(name: 'louis')
        entry = create_entry(user: louis, project: create_project(name: 'Tactic'))
        subject.filter(
          since: entry.created_at.beginning_of_day,
          before: entry.created_at.end_of_day,
          user_ids: [ louis.id.to_s ],
          project_ids: ['0']
        ).wont_include entry
      end
    end
  end
end
