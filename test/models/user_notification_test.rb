require 'test_helper'

describe UserNotification do
  let(:user) { create_user(name: 'louis') }
  subject do
    build_user_notification(
      user: user,
      nature: 'info',
      title: "My title",
      message: "My message"
    )
  end

  it 'is valid' do
    assert subject.valid?
  end
  it 'saves' do
    assert subject.save
  end
  it 'needs a user' do
    subject.user = nil
    refute subject.valid?
  end
  it 'needs a nature' do
    subject.nature = nil
    refute subject.valid?
  end
  it 'nature can be a symbol' do
    subject.nature = :info
    assert subject.valid?
  end
  it 'nature must be in enum' do
    subject.nature = 'invalid'
    refute subject.valid?
  end
  it 'needs a status' do
    subject.status = nil
    refute subject.valid?
  end
  it 'status must be in enum' do
    subject.status = 'invalid'
    refute subject.valid?
  end
  it 'needs either title or message' do
    subject.title = nil
    subject.message = nil
    refute subject.valid?
  end
  it 'is valid without title' do
    subject.title = nil
    assert subject.valid?
  end
  it 'is valid without message' do
    subject.message = nil
    assert subject.valid?
  end
  it 'resource is not required' do
    subject.resource = nil
    assert subject.valid?
  end
  it 'may have a resource' do
    subject.resource = create_entry({ user: user })
    assert subject.valid?
  end
end
