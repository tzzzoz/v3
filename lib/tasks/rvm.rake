RVM_BIN=`which rvm`.chomp
SVN_BIN=`which svn`.chomp

#raise ArgumentError, "Missing rvm binary !" unless File.exists?(RVM_BIN)
#raise ArgumentError, "Missing svn binary !" unless File.exists?(SVN_BIN)

RVM_GEMSET_EXPORT_PATH="doc/pixpalace-rvm.gems"

namespace :rvm do
 namespace :gemset do
   desc "Export current rvm gemset to #{RVM_GEMSET_EXPORT_PATH}"
   task :export do
      sh "#{RVM_BIN} gemset export #{RVM_GEMSET_EXPORT_PATH}"
   end
   desc "Commit rvm gemset"
   task :commit => [:export] do
      sh %Q[#{SVN_BIN} ci #{RVM_GEMSET_EXPORT_PATH} -m '- Export last rvm gemset']
   end
 end
end