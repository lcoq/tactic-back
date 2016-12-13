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
    describe 'With query filter' do
      it 'serialize projects matching query filter' do
        create_project name: 'Cuisine'
        projects = ['Tictac', 'Tactic', 'Tacos'].map { |name| create_project(name: name) }
        get '/projects', headers: headers, params: { 'filter' => { 'query' => 'tac' } }
        assert_response :success
        assert_equal serialized(projects, ProjectSerializer), response.body
      end
    end
  end
end
