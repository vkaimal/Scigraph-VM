SciGraph-vagrant
----------------
This repository is literally [SciGraph](https://github.com/SciCrunch/SciGraph) on a Virtual Debian Wheezy box.

This is the third major update to the SciGraph-vagrant repository.  The big change here is the use of a configuration file (config.lp) to determine 
to specify which ontologies you want to load into the Ontology store.

At the heart of SciGraph-vagrant is the deploy.sh script.  This script 
* reads the config.lp file 
* downloads the necessary ontologies from the specified urls applying all the specified CURIES
* loads all the SciGraph dependencies by running mvn install
* it will even go and clone/pull the latest updates from https://github.com/SciCrunch/SciGraph

The deploy.sh script is currently run as a provisioning step in the Vagrantfile, and so it will load everything up when you type `vagrant up`.
If you wish to run the script manually from within the box you can enter `vagrant up --no-provision` and then go into the box and run the 
deploy script from within the box

Getting Started
---------------
In order to run this box, you need to have [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed on you computer

Once Virtual box and Vagrant are installed, navigate to the directory containing the repository and type vagrant up.
This should cause the virtual machine to download a copy of the preprovisioned box from a remote server.  This process can be time consuming,
depending on your internet connection, but it will only need to be done once.  Once the virtual machine is booted, it will get the latest version of
SciGraph, run all the installation scripts and start the server.  You can simply start using the services.

The deploy.sh script
--------------------
The available parameters for the deploy.sh script are
* -u : pull/clone the latest version of SciGraph from the ttps://github.com/SciCrunch/SciGraph repository.  Basically if SciGraph is not in the current directory
it will clone the repository, otherwise it will pull the latest updates

* -x [name of output config] : this will read the config.lp file, download the listed ontologies into the ontologies folder, and generate the yaml build configuration file
using the [name of output config] as the filename, and a yaml run configuration file using [name of output config]Configuration.  
Please give [name of output config] a .yaml extension.  The -x option will generate the ontologies folder if it does not
exist, and if an ontology specified in the config.lp file is already in the ontologies folder, the deploy script will check to see if there is a later version of that file
and download it, replacing the old file.

* -g [name of build config] : the -g option will build a graph database using the build configuration file specified by [name of build config].  
This the name of the file specified by [name of output config] when using the -x option

* -r [name of run config] : the -r option will start the graph data store (using a jetty server) using the run configuration specified by [name of run config].
This the name of the file specified by [name of output config]Configuration (i.e. the word Configuration is tacked onto the end) when using the -x option
When the -r option starts the jetty server, it will do so using a screen.  The -r option will look for screen on you machine, and if it does not find it, it will
install it for you and start the server on a screen.  You can see the server logs or stop the server by logging into the vagrant box and typing screen -r.

N.B. You do not have to use the -x option to generate you run and build configuration files.  You can use any correctly formatted build and run configurations
of your choosing

It is advisable to run the options in the order in which they are presented...that is to say you should always run the -g option before the -r option etc etc.
* Here is an example of a valid command `./deploy.sh -u -x biologicalOntologies.yaml -g biologicalOntologies.yaml -r biologicalOntologiesConfiguration.yaml`
* This is also valid `./deploy.sh -x biologicalOntologies.yaml -g biologicalOntologies.yaml -r biologicalOntologiesConfiguration.yaml`
* So is this `./deploy.sh -g biologicalOntologies.yaml -r biologicalOntologiesConfiguration.yaml`
* This is not valid `./deploy.sh  -g biologicalOntologies.yaml -r biologicalOntologiesConfiguration.yaml -x biologicalOntologies.yaml`

Also please makes sure you stop the server before running the deploy script

The config.pl file
------------------
This file tells the deploy.sh script which ontologies to load and were to get them from.  The format is as follows
`[full url to the ontology|url] [ontology filename|filename] [alias for CURIE|alias] [url for CURIE|url]`

Please follow the format that is in the default config.lp

It is also very important that you insert ONE newline at the end of the config file.  This is a quirk of the read function in bash that we will try to resolve in
later updates.  Omitting the newline will cause the last entry in the config.pl file to be ignored

Finally due to the massive nature of some of the ontologies, the virtual machine has been set up to use 6GB of RAM.  If this is too much, you can reduce this
in the memory entry of the Vagrantfile.  You might have to reduce the number of ontologies listed in the config.lp file if you do reduce the ram for the virtual machine

For more information on how to Configure Scigraph please visit the original repository at https://github.com/SciCrunch/SciGraph
