require 'test_helper'

describe User do
  subject { build_user(name: 'louis') }

  it 'is valid' do
    assert subject.valid?
  end
  it 'needs a name' do
    subject.name = nil
    refute subject.valid?
  end
  it 'name is unique' do
    subject.name = create_user(name: 'uniqueness-test').name
    refute subject.valid?
  end
  it 'name is unique case-insensitive' do
    subject.name = create_user(name: 'uniqueness-test').name.upcase
    refute subject.valid?
  end

  describe 'Class methods' do
    subject { User }

    it 'default scope orders by created at desc' do
      old_user = create_user(name: 'louis').tap { |u| u.update_column(:created_at, Time.zone.now - 2.hours) }
      new_user = create_user(name: 'adrien').tap { |u| u.update_column(:created_at, Time.zone.now) }
      subject.all.must_equal [new_user, old_user]
    end
  end
end
