require 'test_helper'

describe Teamwork::TimeEntry do
  let(:user) { create_user(name: 'louis') }
  let(:entry) { create_entry(user: user) }
  subject { build_teamwork_time_entry(entry: entry, time_entry_id: 12345) }

  it 'is valid' do
    assert subject.valid?
  end
  it 'needs entry' do
    subject.entry = nil
    refute subject.valid?
  end
  it 'entry is unique' do
    other_entry = create_entry(user: user)
    other_time_entry = create_teamwork_time_entry(entry: other_entry, time_entry_id: 1231292)
    subject.entry = other_entry
    refute subject.valid?
  end
  it 'needs time entry id' do
    subject.time_entry_id = nil
    refute subject.valid?
  end
  it 'time entry id is unique' do
    other_entry = create_entry(user: user)
    other_time_entry = create_teamwork_time_entry(entry: other_entry, time_entry_id: 1231292)
    subject.time_entry_id = other_time_entry.time_entry_id
    refute subject.valid?
  end
end
