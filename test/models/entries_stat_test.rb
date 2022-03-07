require 'test_helper'

describe EntriesStat do
  subject { build_entries_stat(date: today, duration: duration) }
  let(:duration) { 400 }
  let(:today) { Date.today }

  it 'has date' do
    assert_equal today, subject.date
  end

  it 'has duration' do
    assert_equal duration, subject.duration
  end
end
