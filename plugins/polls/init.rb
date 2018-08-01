require "redmine"
Redmine::Plugin.register :polls do
  name 'Polls plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  project_module :poll do
  	permission :view_polls, :polls => :index
  	permission :vote_polls, :polls => :vote
  	permission :create_issue, :polls => :create
    permission :weclome_polls, :polls => :welcome
  end
  menu :project_menu, :poll, { :controller => 'polls', :action => 
'welcome' }, :caption => '票据',:param => :project_id
end