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
  config.vm.provision :shell, inline: "cd #{path}; mvn -DskipTests -DskipITs install"
  config.vm.provision :shell, inline: "cd #{path}/SciGraph-core; mvn exec:java -Dexec.mainClass=\"edu.sdsc.scigraph.owlapi.loader.BatchOwlLoader\" -Dexec.args=\"-c src/test/resources/biologicalOntologies.yaml\""
  config.vm.provision :shell, inline: "cd #{path}/SciGraph-services; mvn exec:java -Dexec.mainClass=\"edu.sdsc.scigraph.services.MainApplication\" -Dexec.args=\"server src/test/resources/biologicalOntologiesConfiguration.yaml\""
end