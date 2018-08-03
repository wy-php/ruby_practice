# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "/Users/poly/www/ruby/practice/log/cron_log.log"

every '* * * * *' do
  rake "practice:tests"
  command "echo 'you can use raw cron syntax too'"
  command "ruby '/Users/poly/www/ruby/practice/test.rb'"
end


﻿#这个只运行在值为:app的roles的服务器中
every :﻿minute, at: '1:37pm', roles: [:app] do
  rake 'app:task' # will only be added to crontabs of :app servers
end
#这个只运行在值为:db的roles的服务器中
every :hour, roles: [:db] do
  rake 'db:task' # will only be added to crontabs of :db servers
end
#这个只运行在任何roles的服务器中
every :day, at: '12:02am' do
  command "run_this_everywhere" # will be deployed to :db and :app servers
end