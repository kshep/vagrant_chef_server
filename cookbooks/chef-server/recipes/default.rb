#
# Author:: Ken Sheppardson (<ken@kshep.net>)
# Cookbook Name:: chef-server
# Recipe:: default
#

package "expect"

# Add the opscode deb repo
apt_repository "opscode" do
  uri "http://apt.opscode.com"
  distribution "lucid-0.10"
  components ["main"]
  key "http://apt.opscode.com/packages@opscode.com.gpg.key"
  action :add
end

# Set the debconf options for the installation process
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

# Install chef client and server
package "chef-server"

# Create chef directory for vagrant user.
directory "/home/vagrant/.chef" do
  owner "vagrant"
  group "vagrant"
  action :create
end

# Copy keys to shared folder so that it can be accessed by test node and host.
bash "cp-chef-pems" do
  user "root"
  code <<-CODE
    cp /etc/chef/validation.pem /home/vagrant/.chef/validation.pem
    cp /etc/chef/webui.pem /home/vagrant/.chef/webui.pem
  CODE
end

# Make sure everything inside the chef directory for the vagrant user is owned
# by the vagrant user.
execute "chown-home-chef" do
  user "root"
  command "chown -R vagrant /home/vagrant/.chef"
  action :run
end

# Create knife-expect.sh script for configuring knife.
cookbook_file "/tmp/knife-expect.sh" do
  source "knife-expect.sh"
  owner "vagrant"
  group "vagrant"
  mode 0700
end

# Configure knife using knife-expect expect script.
execute "configure-knife" do
  cwd "/home/vagrant"
  environment ({'HOME' => '/home/vagrant', 'USER' => "vagrant"})
  user "vagrant"
  command "/tmp/knife-expect.sh"
  not_if "test -e /home/vagrant/.chef/vagrant.pem", :user => 'vagrant'
end

# Create a new knife client account for use on the host.
execute "create-knife-client-user" do
  cwd "/home/vagrant"
  environment ({'HOME' => '/home/vagrant', 'USER' => "vagrant"})
  user "vagrant"
  command "knife client create knife-client-user -d -a -f /tmp/knife-client-user.pem"
  not_if "knife client show knife-client-user", :user => 'vagrant'
end

# Copy knife-client-user.pem to /vagrant after it's created, so that the host
# has access to it. This allows knife to be successfully configured on the host.
execute "copy-knife-client-key" do
  user "vagrant"
  command "cp /tmp/knife-client-user.pem /vagrant"
  not_if "test ! -e /tmp/knife-client-user.pem"
end

# Copy validation.pem to /vagrant after it's created, so that the test node
# has access to it.
execute "copy-validation-key" do
  user "root"
  command "cp /etc/chef/validation.pem /vagrant/"
  not_if "test -e /vagrant/validation.pem"
end
