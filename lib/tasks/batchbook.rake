

namespace :batchbook do

  desc "Add all users in Hipscan Users"
  task :add_users => :environment do
    for user in User.all
      person = BatchBook::Person.new(:first_name => user.username, :last_name => user.username, :company => 'Hipscan Users', :notes => "Created via batchbook API")
      r = person.save
      puts "Added #{user.email}: #{r}"
      person.add_location(:label => 'work', :email => user.email)
      if user.profile_option.blank?
        puts person.add_tag('NoProfile')
      end
    end
  end

end
