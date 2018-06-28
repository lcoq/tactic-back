require 'test_helper'

describe EntryCSV do
  it 'generates CSV' do
    adrien = create_user(name: 'adrien')
    louis = create_user(name: 'louis')

    client1 = create_client(name: "Client 1")
    client1_project1 = create_project(name: "Client 1 project 1", client: client1)
    client1_project2 = create_project(name: "Client 1 project 2", client: client1)

    client2 = create_client(name: "Client 2")
    client2_project1 = create_project(name: "Client 2 project 1", client: client2)

    no_client_project1 = create_project(name: "No client project 1")

    now = Time.zone.now

    entries = [
      build_entry(user: adrien, project: client1_project1, title: "Adrien entry #1", started_at: now, stopped_at: now + 1.hour + 2.minutes),
      build_entry(user: adrien, project: client1_project1, title: "Adrien entry #2", started_at: now, stopped_at: now + 1.hour + 3.minutes),
      build_entry(user: louis, project: client1_project1, title: "Louis entry #1", started_at: now, stopped_at: now + 1.hour + 4.minutes),
      build_entry(user: louis, project: client2_project1, title: "Louis entry #2", started_at: now, stopped_at: now + 1.hour + 5.minutes),
      build_entry(user: louis, project: client2_project1, title: "Louis entry #3", started_at: now, stopped_at: now + 1.hour + 6.minutes),
      build_entry(user: adrien, project: no_client_project1, title: "Adrien entry #3", started_at: now, stopped_at: now + 1.hour + 7.minutes),
      build_entry(user: adrien, project: no_client_project1, title: "Adrien entry #4", started_at: now, stopped_at: now + 1.hour + 8.minutes),
      build_entry(user: louis, project: no_client_project1, title: "Louis entry #4", started_at: now, stopped_at: now + 1.hour + 9.minutes),
      build_entry(user: louis, project: no_client_project1, title: "Louis entry #5", started_at: now, stopped_at: now + 1.hour + 10.minutes)
    ]
    generate_csv(entries).tap do |csv|
      assert_equal entries.length, csv.length
      csv.each_with_index do |row, index|
        assert_equal entries[index].user.name, row['user']
        assert_equal entries[index].project.try(:client).try(:name), row['client']
        assert_equal entries[index].project.try(:name), row['project']
        assert_equal entries[index].title, row['title']
        expected_minutes = "%02.f" % (index+2)
        assert_equal "01:#{expected_minutes}:00", row['duration']
        assert_equal entries[index].started_at.strftime("%d/%m/%Y"), row['date']
        assert_equal entries[index].started_at.strftime("%H:%M"), row['start time']
        assert_equal entries[index].stopped_at.strftime("%H:%M"), row['end time']
     end
    end
  end

  def generate_csv(entries)
    generated = EntryCSV.new(entries).generate
    CSV.parse generated, headers: true
  end
end
