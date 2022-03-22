require 'test_helper'

describe Teamwork::UserConfigSet do
  let(:user) { create_user(name: 'louis') }
  subject { build_teamwork_user_config_set(user: user, set: { 'test' => '123abc' }) }

  it 'is valid' do
    assert subject.valid?
  end
  it 'needs a user' do
    subject.user = nil
    refute subject.valid?
  end
  it 'needs a set' do
    subject.set = nil
    refute subject.valid?
  end
  describe '#has?' do
    it 'is true with string value' do
      assert subject.has?('test')
    end
    it 'is true with false value' do
      subject.set['test'] = false
      assert subject.has?('test')
    end
    it 'is false without value' do
      refute subject.has?('akey')
    end
  end
  describe '#should_keep_without?' do
    it 'is true with other keys' do
      subject.set.update('other' => true)
      assert subject.should_keep_without?('test')
    end
    it 'is false with other key' do
      refute subject.should_keep_without?('test')
    end
  end
  describe '#get_value' do
    it 'returns the stored config value' do
      assert_equal '123abc', subject.get_value('test')
    end
  end
  describe '#update_value' do
    it 'succeeds' do
      assert subject.update_value('test', 'new')
    end
    it 'stores the value' do
      assert subject.save
      subject.update_value('test', 'new')
      subject.reload
      assert_equal 'new', subject.set['test']
    end
  end
  it 'is destroyed when a user is destroyed' do
    assert subject.save
    user.destroy
    refute Teamwork::Domain.find_by(id: subject.id)
  end
end
