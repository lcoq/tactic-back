require 'test_helper'

describe Teamwork::Api::Agent do
  let(:domain) { 'tactic' }
  let(:token) { 'my-token' }
  subject { Teamwork::Api::Agent.new(domain: domain, token: token) }

  describe '#get_task' do
    let(:task_id) { 123 }
    let(:expected_url) { "https://tactic.teamwork.com/projects/api/v3/tasks/123" }
    let(:get_task_stub) { stub_request(:get, expected_url) }

    it 'calls the api' do
      get_task_stub
      response = subject.get_task(task_id)
      assert_requested :get, expected_url
    end
    it 'calls the api with query' do
      query = { test: 'query' }
      get_task_stub.with(query: query)
      response = subject.get_task(task_id, query: query)
      assert_requested :get, expected_url, query: query
    end
    it 'success' do
      get_task_stub
      response = subject.get_task(task_id)
      assert response.success?
    end
    it 'fails' do
      get_task_stub.to_return(status: 500)
      response = subject.get_task(task_id)
      assert response.failure?
    end
    it 'has code' do
      get_task_stub.to_return(status: 204)
      response = subject.get_task(task_id)
      assert_equal 204, response.code
    end
    it 'has body' do
      expected_body = { 'test' => '123' }
      get_task_stub.to_return(body: expected_body.to_json)
      response = subject.get_task(task_id)
      assert_equal expected_body, response.body
    end
  end

  describe '#get_task_times' do
    let(:task_id) { 123 }
    let(:expected_url) { "https://tactic.teamwork.com/projects/api/v3/tasks/123/time" }
    let(:get_task_times_stub) { stub_request(:get, expected_url) }

    it 'calls the api' do
      get_task_times_stub
      response = subject.get_task_times(task_id)
      assert_requested :get, expected_url
    end
    it 'calls the api with query' do
      query = { test: 'query' }
      get_task_times_stub.with(query: query)
      response = subject.get_task_times(task_id, query: query)
      assert_requested :get, expected_url, query: query
    end
    it 'success' do
      get_task_times_stub
      response = subject.get_task_times(task_id)
      assert response.success?
    end
    it 'fails' do
      get_task_times_stub.to_return(status: 500)
      response = subject.get_task_times(task_id)
      assert response.failure?
    end
    it 'has code' do
      get_task_times_stub.to_return(status: 204)
      response = subject.get_task_times(task_id)
      assert_equal 204, response.code
    end
    it 'has body' do
      expected_body = { 'test' => '123' }
      get_task_times_stub.to_return(body: expected_body.to_json)
      response = subject.get_task_times(task_id)
      assert_equal expected_body, response.body
    end
  end

  describe '#patch_task_time' do
    let(:time_id) { 543 }
    let(:expected_url) { "https://tactic.teamwork.com/projects/api/v3/time/543" }
    let(:patch_task_time_stub) { stub_request(:patch, expected_url) }
    let(:attributes) { { test: 1 } }

    it 'calls the api' do
      patch_task_time_stub
      response = subject.patch_task_time(time_id, attributes: attributes)
      assert_requested :patch, expected_url, body: { 'timelog' => attributes }.to_json
    end
    it 'success' do
      patch_task_time_stub
      response = subject.patch_task_time(time_id, attributes: attributes)
      assert response.success?
    end
    it 'fails' do
      patch_task_time_stub.to_return(status: 500)
      response = subject.patch_task_time(time_id, attributes: attributes)
      assert response.failure?
    end
    it 'has code' do
      patch_task_time_stub.to_return(status: 204)
      response = subject.patch_task_time(time_id, attributes: attributes)
      assert_equal 204, response.code
    end
    it 'has body' do
      expected_body = { 'test' => '123' }
      patch_task_time_stub.to_return(body: expected_body.to_json)
      response = subject.patch_task_time(time_id, attributes: attributes)
      assert_equal expected_body, response.body
    end
  end

  describe '#post_task_time' do
    let(:task_id) { 890 }
    let(:expected_url) { "https://tactic.teamwork.com/projects/api/v3/tasks/890/time" }
    let(:post_task_time_stub) { stub_request(:post, expected_url) }
    let(:attributes) { { test: 1 } }

    it 'calls the api' do
      post_task_time_stub
      response = subject.post_task_time(task_id, attributes: attributes)
      assert_requested :post, expected_url, body: { 'timelog' => attributes }.to_json
    end
    it 'success' do
      post_task_time_stub
      response = subject.post_task_time(task_id, attributes: attributes)
      assert response.success?
    end
    it 'fails' do
      post_task_time_stub.to_return(status: 500)
      response = subject.post_task_time(task_id, attributes: attributes)
      assert response.failure?
    end
    it 'has code' do
      post_task_time_stub.to_return(status: 204)
      response = subject.post_task_time(task_id, attributes: attributes)
      assert_equal 204, response.code
    end
    it 'has body' do
      expected_body = { 'test' => '123' }
      post_task_time_stub.to_return(body: expected_body.to_json)
      response = subject.post_task_time(task_id, attributes: attributes)
      assert_equal expected_body, response.body
    end
  end

  describe '#delete_task_time' do
    let(:time_id) { 184 }
    let(:expected_url) { "https://tactic.teamwork.com/projects/api/v3/time/184" }
    let(:delete_task_time_stub) { stub_request(:delete, expected_url) }

    it 'calls the api' do
      delete_task_time_stub
      response = subject.delete_task_time(time_id)
      assert_requested :delete, expected_url
    end
    it 'success' do
      delete_task_time_stub
      response = subject.delete_task_time(time_id)
      assert response.success?
    end
    it 'fails' do
      delete_task_time_stub.to_return(status: 500)
      response = subject.delete_task_time(time_id)
      assert response.failure?
    end
    it 'has code' do
      delete_task_time_stub.to_return(status: 204)
      response = subject.delete_task_time(time_id)
      assert_equal 204, response.code
    end
    it 'has body' do
      expected_body = { 'test' => '123' }
      delete_task_time_stub.to_return(body: expected_body.to_json)
      response = subject.delete_task_time(time_id)
      assert_equal expected_body, response.body
    end
  end
end
