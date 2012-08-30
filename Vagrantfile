Vagrant::Config.run do |config|

  # Chef Server
  config.vm.define :chef_server do |config|
    config.vm.network :hostonly, "172.16.10.2"
    config.vm.box = "lucid64"
    config.vm.forward_port 4000,4000
    config.vm.forward_port 4040,4040

    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.log_level = :debug
      chef.add_recipe "apt"
      chef.add_recipe "chef-server"
      chef.json.merge!({
        :chef_server => {
          :url           => "http://172.16.10.2:4000",
          :amqp_password => "5up3r53cr3t",
          :webui_admin_password => "5up3r53cr3t"
        }
      })
    end
  end

end
