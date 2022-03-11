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
  it 'needs an alias' do
    subject.alias = nil
    refute subject.valid?
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
  it 'is destroyed when a user is destroyed' do
    assert subject.save
    user.destroy
    refute Teamwork::Domain.find_by(id: subject.id)
  end
end
