require 'test_helper.rb'

describe Teamwork::TimeEntrySynchronizer do
  let(:user) { create_user({ name: 'louis' }) }
  let(:entry) do
    create_entry(
      user: user,
      title: "[tc/54321] My description",
      started_at: Time.zone.parse('2022-03-15 19:00:02'),
      stopped_at: Time.zone.parse('2022-03-15 20:01:03')
    )
  end
  let(:tactic_domain) do
    create_teamwork_domain({ user: user, name: 'tactic', alias: 'tc', token: 'tact-token' })
  end
  let(:other_domain) do
    create_teamwork_domain({ user: user, name: 'other', alias: 'ot', token: 'other-token' })
  end
  subject { Teamwork::TimeEntrySynchronizer.new(entry, user: user) }
  before do
    tactic_domain
    other_domain
  end

  describe 'With a new entry' do
    it 'creates a time entry in Teamwork' do
      response = success_api_response('timelog' => { 'id'=> '123321' })
      expected_attributes = {
        description: "My description",
        taskId: 54321,
        date: '2022-03-15',
        time: '19:00:00',
        hours: 1,
        minutes: 1
      }

      agent_mock = Minitest::Mock.new
      agent_mock.expect :post_task_time, response, ['54321', { attributes: expected_attributes } ]

      agent_class_new_mock = Minitest::Mock.new
      agent_class_new_mock.expect :call, agent_mock, [{ domain: 'tactic', token: 'tact-token' }]

      Teamwork::Api::Agent.stub :new, agent_class_new_mock do
        subject.synchronize
      end

      agent_class_new_mock.verify
      agent_mock.verify
    end
    it 'creates a time entry in Teamwork with default rounded duration when config is enabled' do
      Teamwork::UserConfig.find_for_user(user, 'teamwork-task-time-entry-rounding').update_value(true)
      response = success_api_response('timelog' => { 'id'=> '123321' })
      expected_attributes = {
        description: "My description",
        taskId: 54321,
        date: '2022-03-15',
        time: '19:00:00',
        hours: 1,
        minutes: 5
      }

      agent_mock = Minitest::Mock.new
      agent_mock.expect :post_task_time, response, ['54321', { attributes: expected_attributes } ]

      agent_class_new_mock = Minitest::Mock.new
      agent_class_new_mock.expect :call, agent_mock, [{ domain: 'tactic', token: 'tact-token' }]

      Teamwork::Api::Agent.stub :new, agent_class_new_mock do
        subject.synchronize
      end

      agent_class_new_mock.verify
      agent_mock.verify
    end
    it 'creates a time entry locally' do
      response = success_api_response('timelog' => { 'id'=> '123321' })
      expected_attributes = {
        description: "My description",
        taskId: 54321,
        date: '2022-03-15',
        time: '19:00:00',
        hours: 1,
        minutes: 1
      }
      with_api_agent_stub :post_task_time, response, ['54321', { attributes: expected_attributes } ] do
        subject.synchronize
      end
      time_entry = Teamwork::TimeEntry.find_by(entry: entry)
      assert time_entry
      assert_equal 123321, time_entry.time_entry_id
      assert_equal tactic_domain.id, time_entry.domain.id
    end
    it 'does nothing when the title is nil' do
      entry.title = nil
      subject.synchronize
      refute Teamwork::TimeEntry.find_by(entry: entry)
    end
    it 'does nothing when the duration is 0' do
      entry.stopped_at = entry.started_at
      subject.synchronize
      refute Teamwork::TimeEntry.find_by(entry: entry)
    end
    it 'does nothing when the title has no task id' do
      entry.title = "My title"
      subject.synchronize
      refute Teamwork::TimeEntry.find_by(entry: entry)
    end
    it 'does nothing when the entry is not stopped' do
      entry.stopped_at = nil
      subject.synchronize
      refute Teamwork::TimeEntry.find_by(entry: entry)
    end
  end

  describe 'With an entry having a time entry' do
    let(:time_entry) { create_teamwork_time_entry({ entry: entry, domain: tactic_domain, time_entry_id: 15243 })}
    before { time_entry }

    it 'updates the time entry in Teamwork' do
      entry.title = "[ot/12333] New description"
      response = success_api_response('timelog' => { 'id'=> '15243' })
      expected_attributes = {
        description: "New description",
        taskId: 12333,
        date: '2022-03-15',
        time: '19:00:00',
        hours: 1,
        minutes: 1
      }

      agent_mock = Minitest::Mock.new
      agent_mock.expect :patch_task_time, response, [15243, { attributes: expected_attributes } ]

      agent_class_new_mock = Minitest::Mock.new
      agent_class_new_mock.expect :call, agent_mock, [{ domain: 'other', token: 'other-token' }]

      Teamwork::Api::Agent.stub :new, agent_class_new_mock do
        subject.synchronize
      end

      agent_class_new_mock.verify
      agent_mock.verify
    end
    describe 'When the entry title is no longer set' do
      it 'deletes the time entry in Teamwork' do
        entry.title = nil
        response = success_api_response({})

        agent_mock = Minitest::Mock.new
        agent_mock.expect :delete_task_time, response, [15243]

        agent_class_new_mock = Minitest::Mock.new
        agent_class_new_mock.expect :call, agent_mock, [{ domain: 'tactic', token: 'tact-token' }]

        Teamwork::Api::Agent.stub :new, agent_class_new_mock do
          subject.synchronize
        end

        agent_class_new_mock.verify
        agent_mock.verify
      end
      it 'deletes the time entry locally' do
        entry.title = nil
        response = success_api_response({})
        with_api_agent_stub :delete_task_time, response, [15243] do
          subject.synchronize
        end
        refute Teamwork::TimeEntry.find_by(id: time_entry.id)
      end
    end
    describe 'When the entry title no longer has a teamwork task id' do
      it 'deletes the time entry in Teamwork' do
        entry.title = "Title without teamwork identifier"
        response = success_api_response({})

        agent_mock = Minitest::Mock.new
        agent_mock.expect :delete_task_time, response, [15243]

        agent_class_new_mock = Minitest::Mock.new
        agent_class_new_mock.expect :call, agent_mock, [{ domain: 'tactic', token: 'tact-token' }]

        Teamwork::Api::Agent.stub :new, agent_class_new_mock do
          subject.synchronize
        end

        agent_class_new_mock.verify
        agent_mock.verify
      end
      it 'deletes the time entry locally' do
        entry.title = "Title without teamwork identifier"
        response = success_api_response({})
        with_api_agent_stub :delete_task_time, response, [15243] do
          subject.synchronize
        end
        refute Teamwork::TimeEntry.find_by(id: time_entry.id)
      end
    end
    describe 'When the entry is no longer stopped' do
      it 'deletes the time entry in Teamwork' do
        entry.stopped_at = nil
        response = success_api_response({})

        agent_mock = Minitest::Mock.new
        agent_mock.expect :delete_task_time, response, [15243]

        agent_class_new_mock = Minitest::Mock.new
        agent_class_new_mock.expect :call, agent_mock, [{ domain: 'tactic', token: 'tact-token' }]

        Teamwork::Api::Agent.stub :new, agent_class_new_mock do
          subject.synchronize
        end

        agent_class_new_mock.verify
        agent_mock.verify
      end
      it 'deletes the time entry locally' do
        entry.stopped_at = nil
        response = success_api_response({})
        with_api_agent_stub :delete_task_time, response, [15243] do
          subject.synchronize
        end
        refute Teamwork::TimeEntry.find_by(id: time_entry.id)
      end
    end
    describe 'When the entry duration is now 0' do
      it 'deletes the time entry in Teamwork' do
        entry.stopped_at = entry.started_at
        response = success_api_response({})

        agent_mock = Minitest::Mock.new
        agent_mock.expect :delete_task_time, response, [15243]

        agent_class_new_mock = Minitest::Mock.new
        agent_class_new_mock.expect :call, agent_mock, [{ domain: 'tactic', token: 'tact-token' }]

        Teamwork::Api::Agent.stub :new, agent_class_new_mock do
          subject.synchronize
        end

        agent_class_new_mock.verify
        agent_mock.verify
      end
      it 'deletes the time entry locally' do
        entry.stopped_at = entry.started_at
        response = success_api_response({})
        with_api_agent_stub :delete_task_time, response, [15243] do
          subject.synchronize
        end
        refute Teamwork::TimeEntry.find_by(id: time_entry.id)
      end
    end
    describe 'When the entry rounded duration is now 0' do
      it 'deletes the time entry in Teamwork' do
        entry.stopped_at = Time.zone.parse('2022-03-15 19:00:31')
        response = success_api_response({})

        agent_mock = Minitest::Mock.new
        agent_mock.expect :delete_task_time, response, [15243]

        agent_class_new_mock = Minitest::Mock.new
        agent_class_new_mock.expect :call, agent_mock, [{ domain: 'tactic', token: 'tact-token' }]

        Teamwork::Api::Agent.stub :new, agent_class_new_mock do
          subject.synchronize
        end

        agent_class_new_mock.verify
        agent_mock.verify
      end
      it 'deletes the time entry locally' do
        entry.stopped_at = Time.zone.parse('2022-03-15 19:00:31')
        response = success_api_response({})
        with_api_agent_stub :delete_task_time, response, [15243] do
          subject.synchronize
        end
        refute Teamwork::TimeEntry.find_by(id: time_entry.id)
      end
    end
    describe 'When the entry rounded duration is now 0 and rounded config is enabled' do
      it 'deletes the time entry in Teamwork' do
        Teamwork::UserConfig.find_for_user(user, 'teamwork-task-time-entry-rounding').update_value(true)
        entry.stopped_at = Time.zone.parse('2022-03-15 19:01:01')
        response = success_api_response({})

        agent_mock = Minitest::Mock.new
        agent_mock.expect :delete_task_time, response, [15243]

        agent_class_new_mock = Minitest::Mock.new
        agent_class_new_mock.expect :call, agent_mock, [{ domain: 'tactic', token: 'tact-token' }]

        Teamwork::Api::Agent.stub :new, agent_class_new_mock do
          subject.synchronize
        end

        agent_class_new_mock.verify
        agent_mock.verify
      end
      it 'deletes the time entry locally' do
        Teamwork::UserConfig.find_for_user(user, 'teamwork-task-time-entry-rounding').update_value(true)
        entry.stopped_at = Time.zone.parse('2022-03-15 19:01:01')
        response = success_api_response({})
        with_api_agent_stub :delete_task_time, response, [15243] do
          subject.synchronize
        end
        refute Teamwork::TimeEntry.find_by(id: time_entry.id)
      end
    end
  end

  describe 'Destroy' do
    describe 'With an entry having a time entry' do
      let(:time_entry) { create_teamwork_time_entry({ entry: entry, domain: tactic_domain, time_entry_id: 15243 })}
      before { time_entry }

      it 'deletes the time entry in Teamwork' do
        response = success_api_response({})

        agent_mock = Minitest::Mock.new
        agent_mock.expect :delete_task_time, response, [15243]

        agent_class_new_mock = Minitest::Mock.new
        agent_class_new_mock.expect :call, agent_mock, [{ domain: 'tactic', token: 'tact-token' }]

        Teamwork::Api::Agent.stub :new, agent_class_new_mock do
          subject.destroy
        end

        agent_class_new_mock.verify
        agent_mock.verify
      end
      it 'deletes the time entry locally' do
        response = success_api_response({})
        with_api_agent_stub :delete_task_time, response, [15243] do
          subject.destroy
        end
        refute Teamwork::TimeEntry.find_by(id: time_entry.id)
      end
    end
    it 'does nothing without local time entry' do
      subject.destroy
    end
  end

  describe 'With unavailable API' do
    it '#synchronize! raises' do
      response = failure_api_response
      expected_attributes = {
        description: "My description",
        taskId: 54321,
        date: '2022-03-15',
        time: '19:00:00',
        hours: 1,
        minutes: 1
      }
      with_api_agent_stub :post_task_time, response, ['54321', { attributes: expected_attributes } ] do
        assert_raises(Teamwork::TimeEntrySynchronizer::SynchroError) do
          subject.synchronize!
        end
      end
    end
    it '#synchronize creates a background job' do
      delayed_job_mock = Minitest::Mock.new
      delayed_job_mock.expect :call, true do |job|
        job.kind_of?(Teamwork::TimeEntrySynchronizeJob) &&
          job.entry_id == entry.id &&
          job.user_id == user.id
      end
      response = failure_api_response
      expected_attributes = {
        description: "My description",
        taskId: 54321,
        date: '2022-03-15',
        time: '19:00:00',
        hours: 1,
        minutes: 1
      }

      with_api_agent_stub :post_task_time, response, ['54321', { attributes: expected_attributes } ] do
        Delayed::Job.stub :enqueue, delayed_job_mock do
          subject.synchronize
        end
      end

      delayed_job_mock.verify
    end
    it '#destroy! raises' do
      time_entry = create_teamwork_time_entry({ entry: entry, domain: tactic_domain, time_entry_id: 15243 })
      response = failure_api_response
      with_api_agent_stub :delete_task_time, response, [15243] do
        assert_raises(Teamwork::TimeEntrySynchronizer::SynchroError) do
          subject.destroy!
        end
      end
    end
    it '#destroy creates a background job' do
      time_entry = create_teamwork_time_entry({ entry: entry, domain: tactic_domain, time_entry_id: 15243 })

      delayed_job_mock = Minitest::Mock.new
      delayed_job_mock.expect :call, true do |job|
        job.kind_of?(Teamwork::TimeEntryDestroyJob) &&
          job.time_entry_id == time_entry.id &&
          job.entry_title == entry.title &&
          job.entry_started_at == entry.started_at
      end
      response = failure_api_response
      with_api_agent_stub :delete_task_time, response, [15243] do
        Delayed::Job.stub :enqueue, delayed_job_mock do
          subject.destroy
        end
      end

      delayed_job_mock.verify
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
    mock
  end
end
