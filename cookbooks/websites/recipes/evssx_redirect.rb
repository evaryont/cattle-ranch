# This is a *super* basic recipe, to redirect requests to the main page for
# evs.sx to redirect to my personal page at evaryont.me.
#
# TODO: Landing page of some sort, project portfolio? Something should go here,
# probably...
template "#{node['nginx']['dir']}/domains/evs.sx.d/index_redir" do
  source 'evssx_redirect.erb'
  owner  node['nginx']['user']
  group  node['nginx']['group']
  notifies :reload, 'service[nginx]', :delayed
end

