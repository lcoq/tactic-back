require 'test_helper'

describe Teamwork::UserConfig do
  let(:user) { create_user(name: 'louis') }
  let(:set) {  }
  let(:default_value) { true }
  let(:non_default_value) { false }
  let(:definition) { { name: 'test Definition', description: "My description", default: default_value } }
  subject { Teamwork::UserConfig.new(user, definition) }

  it 'id is its parameterized name' do
    assert_equal "test-definition", subject.id
  end
  it 'has description' do
    assert_equal "My description", subject.description
  end
  it 'serializes attributes' do
    create_teamwork_user_config_set(user: user, set: { 'test-definition' => non_default_value })
    results = subject.attributes
    assert_equal 'test Definition', results[:name]
    assert_equal non_default_value, results[:value]
    assert_equal "My description", results[:description]
  end

  describe '#value' do
    it 'is stored value when set' do
      create_teamwork_user_config_set(user: user, set: { 'test-definition' => non_default_value })
      assert_equal non_default_value, subject.value
    end
    it 'is default value without UserConfigSet' do
      assert_equal default_value, subject.value
    end
    it 'is default value with UserConfigSet not having key' do
      create_teamwork_user_config_set(user: user, set: { 'other-definition' => 'anything' })
      assert_equal default_value, subject.value
    end
  end

  describe '#update_value' do
    it 'succeeds on update value' do
      assert subject.update_value(false)
    end
    it 'updates with a non-default value' do
      subject.update_value non_default_value
      assert_equal non_default_value, subject.value
    end
    it 'updates with default value' do
      subject.update_value default_value
      assert_equal default_value, subject.value
    end
    it 'fails with non boolean value' do
      refute subject.update_value "invalid"
    end
    it 'does not update with non boolean value' do
      subject.update_value "invalid"
      assert_equal default_value, subject.value
    end
    describe 'Without existing UserConfigSet' do
      it 'creates UserConfigSet with non-default value and stores it' do
        subject.update_value non_default_value
        set = Teamwork::UserConfigSet.find_by(user: user)
        assert set
        assert_equal non_default_value, set.get_value('test-definition')
      end
      it 'does not create UserConfigSet with default value' do
        subject.update_value default_value
        refute Teamwork::UserConfigSet.find_by(user: user)
      end
    end
    describe 'With existing UserConfigSet having single key' do
      let(:set) { create_teamwork_user_config_set(user: user, set: { 'test-definition' => true }) }
      before { set }

      it 'updates it with non-default value' do
        subject.update_value non_default_value
        assert set.reload
        assert_equal non_default_value, set.get_value('test-definition')
      end
      it 'destroys it with default value' do
        subject.update_value default_value
        refute Teamwork::UserConfigSet.find_by(id: set.id)
      end
    end
    describe 'With existing UserConfigSet having multiple keys' do
      let(:set) { create_teamwork_user_config_set(user: user, set: { 'test-definition' => true, 'other-definition' => true }) }
      before { set }

      it 'updates it with non-default value' do
        subject.update_value non_default_value
        assert set.reload
        assert_equal non_default_value, set.get_value('test-definition')
      end
      it 'removes key with default value' do
        subject.update_value default_value
        assert set.reload
        refute set.has?('test-definition')
      end
    end
  end

  describe 'Class methods' do
    subject { Teamwork::UserConfig }

    it 'builds config for each definitions' do
      results = subject.list_for_user(user)
      assert_equal Teamwork::UserConfig::DEFINITIONS.length, results.length
      Teamwork::UserConfig::DEFINITIONS.each_with_index do |definition, index|
        assert_equal definition, results[index].definition
      end
    end
  end

end
