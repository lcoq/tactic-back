require 'test_helper'

describe ClientsController do
  let(:user) { create_user(name: 'louis') }
  let(:session) { build_session(user: user).tap { |s| assert s.save } }
  let(:headers) { { 'Authorization' => session.token } }

  describe '#index' do
    it 'is forbidden with invalid Authorization header' do
      get '/clients', headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'does not serialize archived clients' do
      create_client(name: 'Archived', archived: true)
      get '/clients', headers: headers
      assert_response :success
      assert_equal serialized([], ClientSerializer), response.body
    end
    it 'serialize clients alphabetically ordered' do
      clients = [
        create_client(name: 'Productivity'),
        create_client(name: 'Efficiency')
      ]
      get '/clients', headers: headers
      assert_response :success
      assert_equal serialized(clients.sort_by(&:name), ClientSerializer), response.body
    end
    it 'include projects' do
      clients = [create_client(name: 'Productivity')]
      create_project(name: 'Tactic', client: clients[0])
      get '/clients', headers: headers, params: { 'include' => 'projects' }
      assert_response :success
      assert_equal serialized(clients, ClientSerializer, include: 'projects'), response.body
    end
  end

  describe '#create' do
    let(:params) do
      {
        'data' => {
          'type' => 'clients',
          'attributes' => {
            'name' => 'Efficiency'
          }
        }
      }
    end

    it 'is forbidden with invalid Authorization header' do
      post "/clients", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'create the client' do
      post "/clients", headers: headers, params: params
      assert_response :success
      client = Client.find_by(name: 'Efficiency')
      assert client
    end
    it 'serialize the client' do
      post "/clients", headers: headers, params: params
      assert_response :success
      client = Client.find_by(name: 'Efficiency')
      assert_equal serialized(client, ClientSerializer), response.body
    end
    describe 'With invalid params' do
      before do
        params['data']['attributes']['name'] = nil
      end
      it 'does not create the client' do
        post "/clients", headers: headers, params: params
        assert_response :unprocessable_entity
      end
      it 'serialize the errors' do
        post "/clients", headers: headers, params: params
        assert_response :unprocessable_entity
        parsed = JSON.parse(response.body)
        parsed['errors'].wont_be_empty
        assert parsed['errors'].any? { | error| error['source']['pointer'] == '/data/attributes/name' }
      end
    end
  end

  describe '#update' do
    let(:client) { create_client(name: 'Productivity') }
    let(:params) do
      {
        'data' => {
          'type' => 'clients',
          'attributes' => {
            'name' => 'Efficiency'
          }
        }
      }
    end

    it 'is forbidden with invalid Authorization header' do
      patch "/clients/#{client.id}", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'update the client' do
      patch "/clients/#{client.id}", headers: headers, params: params
      assert_response :success
      client.reload
      assert_equal 'Efficiency', client.name
    end
    it 'serialize the client' do
      patch "/clients/#{client.id}", headers: headers, params: params
      assert_response :success
      client.reload
      assert_equal serialized(client, ClientSerializer), response.body
    end
    describe 'With invalid params' do
      before do
        params['data']['attributes']['name'] = nil
      end
      it 'does not update the client' do
        patch "/clients/#{client.id}", headers: headers, params: params
        assert_response :unprocessable_entity
      end
      it 'serialize the errors' do
        patch "/clients/#{client.id}", headers: headers, params: params
        assert_response :unprocessable_entity
        parsed = JSON.parse(response.body)
        parsed['errors'].wont_be_empty
        assert parsed['errors'].any? { | error| error['source']['pointer'] == '/data/attributes/name' }
      end
    end
  end

  describe '#destroy' do
    let(:client) { create_client(name: 'Efficiency') }

    it 'is forbidden with invalid Authorization header' do
      delete "/clients/#{client.id}", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'archive the client' do
      delete "/clients/#{client.id}", headers: headers
      assert_response :success
      client.reload
      assert client.archived
    end
    it 'serialize the client' do
      delete "/clients/#{client.id}", headers: headers
      assert_response :success
      assert_equal serialized(client, ClientSerializer), response.body
    end
  end
end
