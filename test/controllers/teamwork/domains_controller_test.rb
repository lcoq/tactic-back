require 'test_helper'

describe Teamwork::DomainsController do
  let(:user) { create_user(name: 'louis') }
  let(:session) { build_session(user: user).tap { |s| assert s.save } }
  let(:headers) { { 'Authorization' => session.token } }

  describe '#index' do
    it 'is forbidden with invalid Authorization header' do
      get '/teamwork/domains', headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'serializes user teamwork domains' do
      domains = [
        create_teamwork_domain(user: user, name: "Tactic", alias: "tc", token: "tactic-token"),
        create_teamwork_domain(user: user, name: "Other", alias: "ot", token: "other-token"),
      ]
      get '/teamwork/domains', headers: headers
      assert_response :success
      assert_equal serialized(domains.sort_by(&:name), Teamwork::DomainSerializer), response.body
    end
    it 'does not serialize other users teamwork domains' do
      other_user = create_user(name: 'adrien')
      create_teamwork_domain(user: other_user, name: "Other", alias: "ot", token: "other-token")
      get '/teamwork/domains', headers: headers
      assert_response :success
      assert_equal serialized([], Teamwork::DomainSerializer), response.body
    end
  end

  describe '#create' do
    let(:params) do
      {
        'data' => {
          'type' => 'teamwork/domains',
          'attributes' => {
            'name' => 'tactic',
            'alias' => 'tc',
            'token' => 'tactic-token'
          }
        }
      }
    end

    it 'is forbidden with invalid Authorization header' do
      get '/teamwork/domains', headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'creates the domain assigned to the current user' do
      post "/teamwork/domains", headers: headers, params: params
      assert_response :success
      domain = Teamwork::Domain.find_by(name: 'tactic')
      assert domain
      assert_equal 'tc', domain.alias
      assert_equal 'tactic-token', domain.token
      assert_equal user, domain.user
    end
    it 'serializes the domain' do
      post "/teamwork/domains", headers: headers, params: params
      assert_response :success
      domain = Teamwork::Domain.find_by(name: 'tactic')
      assert_equal serialized(domain, Teamwork::DomainSerializer), response.body
    end
    describe 'With invalid params' do
      before do
        params['data']['attributes']['name'] = nil
      end
      it 'does not create the domain' do
        post "/teamwork/domains", headers: headers, params: params
        assert_response :unprocessable_entity
      end
      it 'serialize the errors' do
        post "/teamwork/domains", headers: headers, params: params
        assert_response :unprocessable_entity
        parsed = JSON.parse(response.body)
        refute_empty parsed['errors']
        assert parsed['errors'].any? { | error| error['source']['pointer'] == '/data/attributes/name' }
      end
    end
  end

  describe '#update' do
    let(:domain) { create_teamwork_domain(user: user, name: "Tactic", alias: "tc", token: "tactic-token") }
    let(:params) do
      {
        'data' => {
          'type' => 'teamwork/domains',
          'attributes' => {
            'name' => 'Tactic 2',
            'alias' => 'tc2',
            'token' => 'tactic-2-token'
          }
        }
      }
    end

    it 'is forbidden with invalid Authorization header' do
      patch "/teamwork/domains/#{domain.id}", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'updates the domain' do
      patch "/teamwork/domains/#{domain.id}", headers: headers, params: params
      assert_response :success
      domain.reload
      assert_equal 'Tactic 2', domain.name
      assert_equal 'tc2', domain.alias
      assert_equal user, domain.user
    end
    it 'serializes the domain' do
      patch "/teamwork/domains/#{domain.id}", headers: headers, params: params
      assert_response :success
      assert_equal serialized(domain.reload, Teamwork::DomainSerializer), response.body
    end
    describe 'With invalid params' do
      before do
        params['data']['attributes']['name'] = nil
      end
      it 'does not update the domain' do
        patch "/teamwork/domains/#{domain.id}", headers: headers, params: params
        assert_response :unprocessable_entity
      end
      it 'serialize the errors' do
        patch "/teamwork/domains/#{domain.id}", headers: headers, params: params
        assert_response :unprocessable_entity
        parsed = JSON.parse(response.body)
        refute_empty parsed['errors']
        assert parsed['errors'].any? { | error| error['source']['pointer'] == '/data/attributes/name' }
      end
    end
  end

  describe '#destroy' do
    let(:domain) { create_teamwork_domain(user: user, name: "Tactic", alias: "tc", token: "tactic-token") }

    it 'is forbidden with invalid Authorization header' do
      delete "/teamwork/domains/#{domain.id}", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'destroys the domain' do
      delete "/teamwork/domains/#{domain.id}", headers: headers
      assert_response :no_content
      assert_raises(ActiveRecord::RecordNotFound) { domain.reload }
    end
  end
end
