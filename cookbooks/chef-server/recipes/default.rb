#
# Author:: Ken Sheppardson (<ken@kshep.net>)
# Cookbook Name:: chef-server
# Recipe:: default
#

apt_repository "opscode" do
  uri "http://apt.opscode.com"
  distribution "lucid-0.10"
  components ["main"]
  key "http://apt.opscode.com/packages@opscode.com.gpg.key"
  action :add
end

directory "/var/cache/local/preseeding" do
  owner "root"
  group "root"
  mode 0755
  recursive true
end

execute "preseed chef-server" do
  command "debconf-set-selections /var/cache/local/preseeding/chef-server.seed"  
  action :nothing
end

template "/var/cache/local/preseeding/chef-server.seed" do
  source "chef-server.seed.erb"
  owner "root"
  group "root"
  mode "0600"
  notifies :run, resources(:execute => "preseed chef-server"), :immediately
end

package "chef-server"
