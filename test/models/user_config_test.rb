describe UserConfig do
  let(:user) { create_user(name: 'louis', configs: { 'test-definition' => true }) }
  let(:definition_name) { "test Definition" }
  let(:definition) { { name: definition_name, type: :boolean, description: "My description" } }
  subject { UserConfig.new(user, definition) }

  it 'id is its parameterized name' do
    assert_equal "test-definition", subject.id
  end
  it 'has type' do
    assert_equal :boolean, subject.type
  end
  it 'has description' do
    assert_equal "My description", subject.description
  end
  it 'has value' do
    assert_equal true, subject.value
  end
  it 'succeeds on update value' do
    assert subject.update_value(false)
  end
  it 'updates value' do
    subject.update_value false
    assert_equal false, subject.value
  end
  it 'stores value' do
    user.update_attribute :configs, {}
    subject.update_value true
    user.reload
    assert user.configs.key?('test-definition')
    assert_equal true, user.configs['test-definition']
  end
  it 'does not store falsy value' do
    subject.update_value false
    user.reload
    refute user.configs.key?('test-definition')
  end
  it 'serializes attributes' do
    results = subject.attributes
    assert_equal definition_name, results[:name]
    assert_equal :boolean, results[:type]
    assert_equal true, results[:value]
    assert_equal "My description", results[:description]
  end

  describe 'Class methods' do
    subject { UserConfig }

    it 'build config for each user config definitions' do
      results = subject.list_for_user(user)
      assert_equal Globals.user_config_definitions.length, results.length
      Globals.user_config_definitions.each_with_index do |definition, index|
        assert_equal definition, results[index].definition
      end
    end
  end
end
