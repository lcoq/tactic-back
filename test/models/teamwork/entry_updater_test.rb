describe Teamwork::EntryUpdater do
  let(:current_user) { create_user(name: 'louis') }
  let(:entry_user) { create_user(name: 'adrien') }
  let(:entry) { build_entry({ user: entry_user }) }
  let(:teamwork_domain) do
    create_teamwork_domain(
      user: current_user,
      name: 'tactic',
      alias: 'tc',
      token: 'tactic-token'
    )
  end
  subject { Teamwork::EntryUpdater.new(entry, current_user: current_user) }

  describe '#update' do
    it 'succeeds' do
      assert subject.update(title: "My new title")
    end
    it 'fails' do
      refute subject.update(started_at: Time.zone.now, stopped_at: Time.zone.now - 1.hour)
    end
    it 'update attributes' do
      subject.update(title: "My new title")
      entry.reload
      assert_equal "My new title", entry.title
    end
    it 'does not replace task URL in entry title with task name when user has disabled config' do
      Teamwork::UserConfig.find_for_user(current_user, 'teamwork-task-url-replace').update_value(false)
      teamwork_domain
      task_url = "https://tactic.teamwork.com/#/tasks/54321"
      subject.update title: task_url
      entry.reload
      assert_equal task_url, entry.title
    end
    it 'replaces task URL in entry title with teamwork task identifier and task description' do
      teamwork_domain
      task_url = "https://tactic.teamwork.com/#/tasks/54321"
      response = success_api_response('task' => { 'name' => "My task name" })
      with_api_agent_stub :get_task, response, ['54321', { query: { 'fields[task]' => 'name' } }] do |mock|
        subject.update title: task_url
      end
      entry.reload
      assert_equal "[tc/54321] My task name", entry.title
    end
    it 'replaces task URL in entry title with only teamwork task identifier when API is not available' do
      teamwork_domain
      task_url = "https://tactic.teamwork.com/#/tasks/54321"
      response = failure_api_response
      with_api_agent_stub :get_task, response, ['54321', { query: { 'fields[task]' => 'name' } }] do |mock|
        subject.update title: task_url
      end
      entry.reload
      assert_equal "[tc/54321] ", entry.title
    end
  end

  describe '#destroy' do
    it 'succeeds' do
      assert entry.save
      assert subject.destroy
    end
    it 'destroys the entry' do
      assert entry.save
      assert subject.destroy
      refute Entry.find_by(id: entry.id)
    end
  end

  describe 'Class methods' do
    subject { Teamwork::EntryUpdater }

    describe '.use_for?' do
      it 'false when the current user has not teamwork enabled' do
        user = create_user(name: 'louis')
        entry = build_entry({ user: user })
        refute subject.use_for?(entry, current_user: user)
      end
      it 'true when the current user has teamwork enabled' do
        user = create_user(name: 'louis', configs: { 'teamwork' => true })
        entry = build_entry({ user: user })
        assert subject.use_for?(entry, current_user: user)
      end
    end
  end

  def success_api_response(body)
    raw_response = OpenStruct.new(code: 200, body: body.to_json)
    Teamwork::Api::Response.new raw_response
  end

  def failure_api_response
    raw_response = OpenStruct.new(code: 401)
    Teamwork::Api::Response.new raw_response
  end

  def with_api_agent_stub(method, response, arguments)
    mock = Minitest::Mock.new
    mock.expect method, response, arguments
    Teamwork::Api::Agent.stub :new, mock do
      yield
    end
  end

end
