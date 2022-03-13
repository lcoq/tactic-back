describe 'Teamwork initialiation' do

  describe 'Globals' do
    subject { Globals }

    it 'has reviews rounding config' do
      definition = {
        name: 'teamwork',
        type: :boolean,
        description: "Enable to activate Teamwork integration"
      }
      assert_includes subject.user_config_definitions, definition
    end
  end
end
