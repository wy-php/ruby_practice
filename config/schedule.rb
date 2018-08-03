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
every :﻿minute, roles: [:app] do
  command "echo '每分钟运行的，在roles角色为：app下进行的'"
end
#这个只运行在值为:db的roles的服务器中
every :﻿minute, roles: [:db] do
  command "echo '每分钟运行的，在roles角色为：db下进行的'"
end
#这个只运行在任何roles的服务器中
every :minute do
  command "echo '每分钟运行的'"
end