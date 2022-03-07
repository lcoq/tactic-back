require 'test_helper'

describe EntriesStatGroup do
  let(:title) { "My stat group" }
  let(:nature) { "hour/day" }
  let(:entries_stats) { 3.times.map { build_entries_stat({}) } }
  subject { build_entries_stat_group(title: title, nature: nature, entries_stats: entries_stats) }

  it 'has title' do
    assert_equal title, subject.title
  end

  it 'has nature' do
    assert_equal nature, subject.nature
  end

  it 'has entries stats' do
    assert_equal entries_stats.length, subject.entries_stats.length
  end
end
