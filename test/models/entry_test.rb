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
  end
end
