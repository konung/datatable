namespace :datatable do

  # Put w/e people will need to bootstrap development
  desc 'pass DB=mysql or pg'
  task :setup do

    fail 'Please pass DB=pg or DB=mysql' unless ENV['DB']
    `cp config/database.yml.#{ENV['DB']} config/database.yml`

  end

end
