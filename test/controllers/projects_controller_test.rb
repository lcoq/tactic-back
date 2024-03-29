require 'test_helper'

describe ProjectsController do
  let(:user) { create_user(name: 'louis') }
  let(:session) { build_session(user: user).tap { |s| assert s.save } }
  let(:headers) { { 'Authorization' => session.token } }

  describe '#index' do
    it 'is forbidden with invalid Authorization header' do
      get '/projects', headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'does not serialize archived projects' do
      create_project(name: 'Archived', archived: true)
      get '/projects', headers: headers
      assert_response :success
      assert_equal serialized([], ProjectSerializer), response.body
    end
    it 'serialize projects alphabetically ordered' do
      projects = [
        create_project(name: 'Tactic'),
        create_project(name: 'Tictoc'),
        create_project(name: 'Cuisine')
      ]
      get '/projects', headers: headers
      assert_response :success
      assert_equal serialized(projects.sort_by(&:name), ProjectSerializer), response.body
    end
    it 'includes clients' do
      client = create_client(name: 'Productivity')
      projects = [create_project(name: 'Tactic')]
      get '/projects', headers: headers, params: { 'include' => 'client' }
      assert_response :success
      assert_equal serialized(projects, ProjectSerializer, include: 'client'), response.body
    end
    describe 'With query filter' do
      it 'serialize projects matching query filter' do
        create_project name: 'Cuisine'
        projects = ['Tictac', 'Tactic', 'Tacos'].map { |name| create_project(name: name) }
        get '/projects', headers: headers, params: { 'filter' => { 'query' => 'tac' } }
        assert_response :success
        assert_equal serialized(projects, ProjectSerializer), response.body
      end
      it 'does not serialize archived projects matching query filter' do
        project = create_project(name: 'Archived', archived: true)
        get '/projects', headers: headers, params: { 'filter' => { 'query' => project.name } }
        assert_response :success
        assert_equal serialized([], ProjectSerializer), response.body
      end
    end
  end

  describe '#create' do
    let(:client) { create_client(name: 'Productivity') }
    let(:params) do
      {
        'data' => {
          'type' => 'projects',
          'attributes' => {
            'name' => 'Tictac'
          },
          'relationships' => {
            'client' => {
              'data' => {
                'type' => 'clients',
                'id' => client.id.to_s
              }
            }
          }
        }
      }
    end

    it 'is forbidden with invalid Authorization header' do
      post "/projects", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'create the project' do
      post "/projects", headers: headers, params: params
      assert_response :success
      project = Project.find_by(name: 'Tictac')
      assert project
      assert_equal client, project.client
    end
    it 'serialize the project' do
      post "/projects", headers: headers, params: params
      assert_response :success
      project = Project.find_by(name: 'Tictac')
      assert_equal serialized(project, ProjectSerializer), response.body
    end
    describe 'With invalid params' do
      before do
        params['data']['attributes']['name'] = nil
      end
      it 'does not create the project' do
        post "/projects", headers: headers, params: params
        assert_response :unprocessable_entity
      end
      it 'serialize the errors' do
        post "/projects", headers: headers, params: params
        assert_response :unprocessable_entity
        parsed = JSON.parse(response.body)
        refute_empty parsed['errors']
        assert parsed['errors'].any? { | error| error['source']['pointer'] == '/data/attributes/name' }
      end
    end
  end

  describe '#update' do
    let(:project) { create_project(name: 'Tactic') }
    let(:client) { create_client(name: 'Productivity') }
    let(:params) do
      {
        'data' => {
          'type' => 'projects',
          'attributes' => {
            'name' => 'Tictac'
          },
          'relationships' => {
            'client' => {
              'data' => {
                'type' => 'clients',
                'id' => client.id.to_s
              }
            }
          }
        }
      }
    end

    it 'is forbidden with invalid Authorization header' do
      patch "/projects/#{project.id}", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'update the project' do
      patch "/projects/#{project.id}", headers: headers, params: params
      assert_response :success
      project.reload
      assert_equal 'Tictac', project.name
      assert_equal client, project.client
    end
    it 'serialize the project' do
      patch "/projects/#{project.id}", headers: headers, params: params
      assert_response :success
      project.reload
      assert_equal serialized(project, ProjectSerializer), response.body
    end
    describe 'With invalid params' do
      before do
        params['data']['attributes']['name'] = nil
      end
      it 'does not update the project' do
        patch "/projects/#{project.id}", headers: headers, params: params
        assert_response :unprocessable_entity
      end
      it 'serialize the errors' do
        patch "/projects/#{project.id}", headers: headers, params: params
        assert_response :unprocessable_entity
        parsed = JSON.parse(response.body)
        refute_empty parsed['errors']
        assert parsed['errors'].any? { | error| error['source']['pointer'] == '/data/attributes/name' }
      end
    end
  end

  describe '#destroy' do
    let(:project) { create_project(name: 'Tactic') }

    it 'is forbidden with invalid Authorization header' do
      delete "/projects/#{project.id}", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'archive the project' do
      delete "/projects/#{project.id}", headers: headers
      assert_response :success
      project.reload
      assert project.archived
    end
    it 'serialize the project' do
      delete "/projects/#{project.id}", headers: headers
      assert_response :success
      assert_equal serialized(project, ProjectSerializer), response.body
    end
  end
end
