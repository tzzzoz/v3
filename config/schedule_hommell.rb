# -*- encoding : utf-8 -*-
# Learn more: http://github.com/javan/whenever

env :PATH, "/home/v2/.rvm/gems/ruby-2.0.0-p247@pixpalace/bin:/home/v2/.rvm/gems/ruby-2.0.0-p247@global/bin:/home/v2/.rvm/rubies/ruby-2.0.0-p247/bin:/home/v2/.rvm/bin:/home/v2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
env :RUBY_VERSION, 'ruby-2.0.0-p247'
env :GEM_HOME, '/home/v2/.rvm/gems/ruby-2.0.0-p247@pixpalace'
env :GEM_PATH, '/home/v2/.rvm/gems/ruby-2.0.0-p247@pixpalace:/home/v2/.rvm/gems/ruby-2.0.0-p247@global'
job_type :indexer, '/usr/bin/indexer --config :task :which_delta'


every '10,30,50 * * * *' do
  indexer "/var/www/v2/current/config/production.sphinx.conf --rotate", :which_delta => "statistic_delta"
end


every '0,10,20,30,40,50 * * * *' do
  command "/var/www/v2/current/tools/file_processor/script/fs_reader -LH /home/photolocal"
end

every '5,15,25,35,45,55 * * * *' do
  command "/var/www/v2/current/tools/file_processor/script/fs_reader -LH /home/photolocal2"
end


set :output, '/var/log/pixways/get_rep_json.log'
every '5,15,25,35,45,55 * * * *' do
  command "cd /var/www/v2/current/tools && RAILS_ENV=production ruby get_rep_json.rb"
end

set :output, '/var/log/pixways/cs.log'
every 1.day, :at => '22:00' do
  command "/var/www/v2/current/script/cs.sh"
end

