require 'test_helper'

describe Teamwork::Domain do
  let(:user) { create_user(name: 'louis') }
  subject { build_teamwork_domain(user: user, name: 'tactic', alias: 'tc', token: 'my-token') }

  it 'is valid' do
    assert subject.valid?
  end
  it 'needs a user' do
    subject.user = nil
    refute subject.valid?
  end
  it 'needs a name' do
    subject.name = nil
    refute subject.valid?
  end
  it 'name is unique by user' do
    create_teamwork_domain(user: user, name: subject.name, alias: 'other-alias', token: 'other-token')
    refute subject.valid?
  end
  it 'name is not unique for different users' do
    other_user = create_user(name: 'adrien')
    create_teamwork_domain(user: other_user, name: subject.name, alias: 'other-alias', token: 'other-token')
    assert subject.valid?
  end
  it 'alias is set to its name when empty' do
    subject.alias = ''
    assert subject.save
    assert_equal subject.name, subject.alias
  end
  it 'alias is unique by user' do
    create_teamwork_domain(user: user, name: 'other-name', alias: subject.alias, token: 'other-token')
    refute subject.valid?
  end
  it 'alias is not unique for different users' do
    other_user = create_user(name: 'adrien')
    create_teamwork_domain(user: other_user, name: 'other-name', alias: subject.alias, token: 'other-token')
    assert subject.valid?
  end
  it 'needs a token' do
    subject.token = nil
    refute subject.valid?
  end
  it 'destroys its time entries' do
    subject.destroy
    refute Teamwork::TimeEntry.find_by(id: subject.id)
  end
  it 'is destroyed when a user is destroyed' do
    assert subject.save
    entry = create_entry({ user: user })
    time_entry = create_teamwork_time_entry(entry: entry, domain: subject, time_entry_id: 12345)
    subject.destroy
    refute Teamwork::TimeEntry.find_by(id: time_entry.id)
  end
end
