Vagrant.configure("2") do |config|
  config.vm.box = "scigraphbox"
  config.vm.box_url = "https://s3.amazonaws.com/kabenla_boxes/scigraph.box"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", 2048]
  end

  project = 'SciGraph'
  path = "/var/www/sites/#{project}"

  config.vm.synced_folder ".", "/vagrant", :disabled => true
  config.vm.synced_folder ".", "/var/www/sites/SciGraph", :nfs => true
  config.vm.hostname = "#{project}.dev"

  config.ssh.forward_agent  = true
  config.vm.network :private_network, ip: "10.33.36.99"
  config.vm.provision :shell, inline: "if [[ ! -d 'SciGraph' ]] then ./deploy.sh -u"
  config.vm.provision :shell, inline: "mvn exec:java -Dexec.mainClass=\"edu.sdsc.scigraph.owlapi.loader.BatchOwlLoader\" -Dexec.args=\"-c build_configurations/biologicalOntologies.yaml\""
  config.vm.provision :shell, inline: "mvn exec:java -Dexec.mainClass=\"edu.sdsc.scigraph.services.MainApplication\" -Dexec.args=\"server run_configurations/biologicalOntologiesConfiguration.yaml\""
end
