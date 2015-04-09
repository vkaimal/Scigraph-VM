SciGraph-vagrant
----------------
This repository is a second attempt at get the [SciGraph](https://github.com/SciCrunch/SciGraph) on a Virtual Debian Wheezy box.
The firest version of SciGraph-vagrant had some serious short comings because it made it very difficult the update SciGraph.
In this version of SciGraph-vagrant, we have completely abstracted out of the SciGraph portion (you will notice it is currently
ignored in the .gitignore file).  All items like the build and run configuration yaml files as well as the targets and ontologies
that they point to are now outside of the Scigraph repository.

A deploy bash script `deploy.sh` is no responsible for cloning and updating the Scigraph repository when you run `vagrant up`.
This deploy script can has options to update `-u` or switch to any branch of SciGraph `-b <branch name>`.  The deploy script will
update or switch branches, and then run mvn -DskipTests -DskipITs install.  You will then have to build the graphs and start the 
server.

Getting Started
---------------
In order to run this box, you need to have [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed on you computer

Once Virtual box and Vagrant are installed, navigate to the directory containing the repository and type vagrant up.
This should cause the virtual machine to download a copy of the preprovisioned box from a remote server.  This process can be time consuming,
depending on your internet connection, but it will only need to be done once.  Once the virtual machine is booted, it will get the latest version of
SciGraph, run all the installation scripts and start the server.  You can simply start using the services.  If you which to ssh into the box,
open another terminal, navigate to the repository and type `vagrant ssh`.

The box is configured to load up the following ontologies
* doid
* MeSH
* hp

You may change which ontologies are loaded by modifying the `build_configurations/biologicalOntologies.yaml` file.
NB Even through the configurations are setup to load these ontologies, the ontologies are not in this repository because some of the are huge.
You can download Ontologies from 

* https://s3.amazonaws.com/ontologies-bucket/doid.owl
* https://s3.amazonaws.com/ontologies-bucket/mesh.owl
* https://s3.amazonaws.com/ontologies-bucket/hp.owl

Put these ontologies into the `ontologies` folder

For more information on how to Configure Scigraph please visit the original repository at https://github.com/SciCrunch/SciGraph
