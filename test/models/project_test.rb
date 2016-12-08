require 'test_helper'

describe Project do
  subject { build_project(name: 'Tactic') }

  it 'is valid' do
    assert subject.valid?
  end
  it 'needs a name' do
    subject.name = nil
    refute subject.valid?
  end
  it 'name is unique' do
    subject.name = create_project(name: 'uniqueness-test').name
    refute subject.valid?
  end
  it 'name is unique case-insensitive' do
    subject.name = create_project(name: 'uniqueness-test').name.upcase
    refute subject.valid?
  end
  describe '#destroy' do
    it 'clears its references on entries' do
      assert subject.save
      user = create_user(name: 'louis')
      entry = create_entry(title: 'project-destroy-test', project: subject, user: user)
      subject.destroy
      refute entry.reload.project_id
    end
  end

  describe 'Class methods' do
    subject { Project }

    describe '#search_by_name' do
      it 'includes entries having its name equal to the query' do
        project = create_project(name: 'Tactic')
        subject.search_by_name('Tactic').must_include project
      end
      it 'includes entries having its name equal to the query with different case' do
        project = create_project(name: 'Tactic')
        subject.search_by_name('tactic').must_include project
      end
      it 'includes entries having part of its name equal to the query with different case' do
        project = create_project(name: 'Tactic')
        subject.search_by_name('tac').must_include project
      end
      it 'does not include entries with different name than the query' do
        project = create_project(name: 'Cuisine')
        subject.search_by_name('tactic').wont_include project
      end
    end
  end
end
