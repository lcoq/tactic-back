require 'test_helper'

describe Teamwork::TimeEntry do
  let(:user) { create_user(name: 'louis') }
  let(:domain) { create_teamwork_domain({ user: user, name: 'tactic', alias: 'tc', token: 'tc-token' }) }
  let(:entry) { create_entry(user: user) }
  subject { build_teamwork_time_entry(entry: entry, domain: domain, time_entry_id: 12345) }

  it 'is valid' do
    assert subject.valid?
  end
  it 'needs entry' do
    subject.entry = nil
    refute subject.valid?
  end
  it 'needs domain' do
    subject.domain = nil
    refute subject.valid?
  end
  it 'get domain_id' do
    assert_equal subject.domain_id, subject.domain.id
  end
  it 'set domain id' do
    other_domain = create_teamwork_domain({ user: user, name: 'other', alias: 'ot', token: 'ot-token' })
    subject.domain_id = other_domain.id
    assert_equal other_domain, subject.domain
  end
  it 'entry is unique' do
    other_entry = create_entry(user: user)
    other_time_entry = create_teamwork_time_entry(entry: other_entry, domain: domain, time_entry_id: 1231292)
    subject.entry = other_entry
    refute subject.valid?
  end
  it 'needs time entry id' do
    subject.time_entry_id = nil
    refute subject.valid?
  end
  it 'time entry id is unique' do
    other_entry = create_entry(user: user)
    other_time_entry = create_teamwork_time_entry(entry: other_entry, domain: domain, time_entry_id: 1231292)
    subject.time_entry_id = other_time_entry.time_entry_id
    refute subject.valid?
  end
  it 'Entry#destroy does not raises with a TimeEntry' do
    assert subject.save
    entry.destroy
  end
end
