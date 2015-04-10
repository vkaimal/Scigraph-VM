#!/bin/bash
echo "Hello and welcome the SciGraph-Vagrant deployment system"
usage()
{
  cat << EOF
  usage: $0 options

  This script script will clone the SciGraph repository if the SciGraph folder does not exist

  OPTIONS:
    -h  Show this message
    -u  Updates the current branch of the SciGraph repository or clones the SciGraph repository if no SciGraph folder is found
    -b  Deploy (checkout) a specified branch.
    -g  Generates Neo4j graph from ontology with a given configuration.yml file
    -r 	Run service ontology store service using with a given configuration.yml file
    -i  Gets information about available branches
EOF
}

function generate_neo4j_graph(){
  if [[ ! -z $runontservice ]]
  then
    echo "Please run the deploy script with the -g option before the -r option"
    exit 1
  fi

	if [[ -d 'SciGraph/SciGraph-core' ]]
	then
		pushd SciGraph/SciGraph-core
		if [[ -e ../../build_configurations/$1 ]]
		then
			mvn exec:java -Dexec.mainClass="edu.sdsc.scigraph.owlapi.loader.BatchOwlLoader" -Dexec.args="-c ../../build_configurations/$1"
      popd
			#echo "starting build from $1 configuration"
		else
			echo "$1 not found in build_configurations folder"
			exit 1
		fi
	else
		echo "Your SciGraph folder is incomplete.  Please delete the SciGraph folder and run the deploy script with the -u parameter"
		exit 1
	fi
}

function start_ontology_service(){
	if [[ -d 'SciGraph/SciGraph-services' ]]
	then
		pushd SciGraph/SciGraph-services
		if [[ -e ../../run_configurations/$1 ]]
		then
			screen mvn exec:java -Dexec.mainClass="edu.sdsc.scigraph.services.MainApplication" -Dexec.args="server ../../run_configurations/$1"
      screen -d
			#echo "running service from $1 configuration"
		else
			echo "$1 not found in run_configurations folder"
			exit 1
		fi
	else
		echo "Your SciGraph folder is incomplete.  Please delete the SciGraph folder and run the deploy script with the -u parameter"
		exit 1
	fi
}

function update_scigraph(){
  if [[ ! -z $runontservice ]]
  then
    echo "Please run the deploy script with the -u option before the -r option"
    exit 1
  fi
  
  if [[ -d 'SciGraph' ]]
  then
    pushd SciGraph
    git pull https://github.com/SciCrunch/SciGraph.git
    if [[ $? -eq 0 ]]
    then
      echo "running maven install"
      mvn -DskipTests -DskipITs install
      popd
    else
      echo "No git repository was found in the SciGraph folder"
      echo "Delete the SciGraph folder and run deply with the -u option"
      exit 1
    fi
  else
    echo 'SciGraph directory not found'
    git clone https://github.com/SciCrunch/SciGraph.git
    pushd SciGraph
    echo "running maven install"
    mvn -DskipTests -DskipITs install
    popd
  fi
}

function checkout_scigraph_branch(){
  if [[ ! -z $runontservice ]]
  then
    echo "Please run the deploy script with the -b option before the -r option"
    exit 1
  fi
  if [[ -d 'SciGraph' ]]
  then
    pushd SciGraph
    git checkout $1
    if [[ $? -eq 0 ]]
    then
      echo "running maven install"
      mvn -DskipTests -DskipITs install
      popd
    fi
  else
    echo 'SciGraph directory not found'
    echo 'Please run the deploy script with the -u option first'
    exit 1
  fi
}

function show_branches(){
  if [[ -d 'SciGraph' ]]
  then
    cd SciGraph
    git branch -a
    echo 'Your current branch is demarkated with a star'
    exit 0
  fi
}

while getopts ":hug:r:ib:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    u)
      update_scigraph
      ;;
    g)
      genneo4jconfig=$OPTARG
      generate_neo4j_graph $genneo4jconfig
      ;;
    r)
	  runontservice=$OPTARG
	  start_ontology_service $runontservice
	  ;;
    b)
      checkoutbranch=$OPTARG
      checkout_scigraph_branch $checkoutbranch
      ;;
    i)
      show_branches
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done
