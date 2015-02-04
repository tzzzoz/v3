# -*- encoding : utf-8 -*-
# Learn more: http://github.com/javan/whenever

env :PATH, "/home/v2/.rvm/gems/ruby-1.9.3-p392@pixpalace/bin:/home/v2/.rvm/gems/ruby-1.9.3-p392@global/bin:/home/v2/.rvm/rubies/ruby-1.9.3-p392/bin:/home/v2/.rvm/bin:/home/v2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
env :RUBY_VERSION, 'ruby-1.9.3-p392'
env :GEM_HOME, '/home/v2/.rvm/gems/ruby-1.9.3-p392@pixpalace'
env :GEM_PATH, '/home/v2/.rvm/gems/ruby-1.9.3-p392@pixpalace:/home/v2/.rvm/gems/ruby-1.9.3-p392@global'
job_type :indexer, '/usr/bin/indexer --config :task :which_delta'


every '5,15,25,35,45,55 * * * *' do
  indexer "/var/www/v2/current/config/production.sphinx.conf --rotate", :which_delta => "image_delta"
end

every '0,30 * * * *' do
  indexer "/var/www/v2/current/config/production.sphinx.conf --rotate", :which_delta => "statistic_delta"
end


set :output, 'log/cron.log'

every :monday, :at => '07:30' do
  runner "Image.delete_PA_only"
end

every :monday, :at => '09:00' do
  runner "Statistic.stats_downloads"
end

every 1.month, :at => 'January 1st 08:00' do
  runner "Provider.send_yas"
end

every 1.month, :at => 'January 1st 08:30' do
  runner "Provider.stats_3months"
end


set :output, '/var/log/pixways/send_features.log'
every '0,10,20,30,40,50 * * * *' do
  command "/var/www/v2/current/script/send_features.sh"
end

set :output, '/var/log/pixways/pixadmin.log'
every 1.day, :at => '22:00' do
  command "/var/www/v2/current/script/pixadmin.sh"
end

