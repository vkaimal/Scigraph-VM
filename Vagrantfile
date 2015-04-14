$script = <<SCRIPT
cd /var/www/sites/SciGraph-vagrant
./deploy.sh -u -x biologicalOntologies.yaml -g biologicalOntologies.yaml -r biologicalOntologiesConfiguration.yaml
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "scigraphbox"
  config.vm.box_url = "https://s3.amazonaws.com/kabenla_boxes/scigraph.box"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", 2048]
  end

  project = 'SciGraph-vagrant'
  path = "/var/www/sites/#{project}"

  config.vm.synced_folder ".", "/vagrant", :disabled => true
  config.vm.synced_folder ".", "/var/www/sites/SciGraph-vagrant", :nfs => true
  config.vm.hostname = "#{project}.dev"

  config.ssh.forward_agent  = true
  config.vm.network :private_network, ip: "10.33.36.99"
  config.vm.provision :shell, inline: $script, privileged: false
end
