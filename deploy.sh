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

function initialize_scigraph_build_configuration_file(){
  if [[ ! -d 'build_configurations' ]]
  then
    mkdir build_configurations
  fi

  if [[ ! -d 'build_configurations/target' ]]
  then
    mkdir build_configurations/target
  fi

  if [[ -e build_configurations/$1 ]]
  then
    mv build_configurations/$1 build_configurations/$1.old
    touch build_configurations/$1
    before_ontologies_section='yes'
    OLD_IFS="$IFS"
    IFS=
    while read graph_build_config_details
    do
      if [[ $before_ontologies_section == 'yes' ]]
      then
        echo $graph_build_config_details >> build_configurations/$1
        if  [[ $graph_build_config_details == 'ontologies:' ]]
        then
          before_ontologies_section='no'
        fi
      fi
    done < build_configurations/$1.old
    IFS="$OLD_IFS"
  else
    filename=$1
    target_directory=${filename%.yaml} 
    echo 'graphConfiguration:'>build_configurations/$1
    echo '    location: ../../build_configurations/target/'$target_directory>>build_configurations/$1
    echo '    indexedNodeProperties:'>>build_configurations/$1
    echo '      - category'>>build_configurations/$1
    echo '      - label'>>build_configurations/$1
    echo '      - fragment'>>build_configurations/$1
    echo '    exactNodeProperties:'>>build_configurations/$1
    echo '      - label'>>build_configurations/$1
    echo '      - synonym'>>build_configurations/$1
    echo 'ontologies:'>>build_configurations/$1
  fi

  if [[ ! -d 'ontologies' ]]
  then
    mkdir ontologies
  fi
}

function initialize_scigraph_run_configuration_file(){
  if [[ ! -d 'run_configurations' ]]
  then
    mkdir run_configurations
  fi

  if [[ ! -e run_configurations/$1 ]]
  then
    echo 'server:'>run_configurations/$1
    echo '  type: simple'>>run_configurations/$1
    echo '  applicationContextPath: /scigraph'>>run_configurations/$1
    echo '  adminContextPath: /admin'>>run_configurations/$1
    echo '  connector:'>>run_configurations/$1
    echo '    type: http'>>run_configurations/$1
    echo '    port: 9000'>>run_configurations/$1
    echo 'logging:'>>run_configurations/$1
    echo '  level: INFO'>>run_configurations/$1
    echo 'graphConfiguration:'>>run_configurations/$1
    echo '  location: ../../build_configurations/target/biologicalOntologies'>>run_configurations/$1
    echo '  indexedNodeProperties:'>>run_configurations/$1
    echo '    - category'>>run_configurations/$1
    echo '    - label'>>run_configurations/$1
    echo '    - fragment'>>run_configurations/$1
    echo '  exactNodeProperties:'>>run_configurations/$1
    echo '    - label'>>run_configurations/$1
    echo '    - synonym'>>run_configurations/$1
    echo '  curies:'>>run_configurations/$1
    echo "    'HP': 'http://purl.obolibrary.org/obo/HP_'" >> run_configurations/$1
    echo "    'DOID': 'http://purl.obolibrary.org/obo/DOID_'" >> run_configurations/$1
    echo "    'MESH': 'http://phenomebrowser.net/ontologies/mesh/mesh.owl#'" >> run_configurations/$1
    echo "    'OBI': 'http://purl.obolibrary.org/obo/OBI_'" >> run_configurations/$1
    echo "    'GO': 'http://purl.obolibrary.org/obo/GO_'" >> run_configurations/$1
    echo "    'CHEBI': 'http://purl.obolibrary.org/obo/CHEBI_'" >> run_configurations/$1
    echo "    'SO': 'http://purl.obolibrary.org/obo/SO_'" >> run_configurations/$1
    echo "    'FMA': 'http://purl.obolibrary.org/obo/FMA_'" >> run_configurations/$1
    echo "    'CL': 'http://purl.obolibrary.org/obo/CL_'" >> run_configurations/$1
    echo "    'HUGO': 'http://ncicb.nci.nih.gov/xml/owl/EVS/Hugo.owl#'" >> run_configurations/$1
    echo "    'OMIM': 'http://purl.bioontology.org/ontology/OMIM'" >> run_configurations/$1
    echo "serviceMetadata:" >> run_configurations/$1
    echo "  name: 'Pizza Reconciliation Service'" >> run_configurations/$1
    echo "  identifierSpace: 'http://example.org'" >> run_configurations/$1
    echo "  schemaSpace: 'http://example.org'" >> run_configurations/$1
    echo "  view: {" >> run_configurations/$1
    echo "    url: 'http://localhost:9000/scigraph/refine/view/{{id}}'" >> run_configurations/$1
    echo "  }" >> run_configurations/$1
    echo "  preview: {" >> run_configurations/$1
    echo "    url: 'http://localhost:9000/scigraph/refine/preview/{{id}}'," >> run_configurations/$1
    echo "    width: 400," >> run_configurations/$1
    echo "    height: 400" >> run_configurations/$1
    echo "  }" >> run_configurations/$1
  fi
}


function insert_scigraph_graph_ontology(){
  echo '  - url: ../../ontologies/'$2 >> build_configurations/$1
  echo '    reasonerConfiguration:' >> build_configurations/$1
  echo '      factory: org.semanticweb.elk.owlapi.ElkReasonerFactory' >> build_configurations/$1
}

function insert_scigraph_graph_data_after_ontologies(){
  if [[ ! -e build_configurations/$1.old ]]
  then
    echo 'categories:' >> build_configurations/$1
    echo '    http://purl.obolibrary.org/obo/HP_0001909 : leukemia' >> build_configurations/$1
    echo '    http://purl.obolibrary.org/obo/HP_0001911 : granulocytes' >> build_configurations/$1
    echo 'mappedProperties:' >> build_configurations/$1
    echo '  - name: label # The name of the new property' >> build_configurations/$1
    echo '    properties: # The list of properties mapped to the new property' >> build_configurations/$1
    echo '    - http://www.w3.org/2000/01/rdf-schema#label' >> build_configurations/$1
    echo '    - http://www.w3.org/2004/02/skos/core#prefLabel' >> build_configurations/$1
    echo '  - name: comment' >> build_configurations/$1
    echo '    properties:' >> build_configurations/$1
    echo '    - http://www.w3.org/2000/01/rdf-schema#comment' >> build_configurations/$1
    echo '  - name: synonym' >> build_configurations/$1
    echo '    properties:' >> build_configurations/$1
    echo '    - http://www.geneontology.org/formats/oboInOwl#hasExactSynonym' >> build_configurations/$1
    echo '    - http://purl.obolibrary.org/obo#Synonym' >> build_configurations/$1
    echo '    - http://purl.obolibrary.org/obo/go#systematic_synonym' >> build_configurations/$1
    echo '    - http://www.w3.org/2004/02/skos/core#altLabel' >> build_configurations/$1
  else
    in_ontologies_section='no'
    past_ontologies_section='no'
    OLD_IFS="$IFS"
    IFS=
    while read graph_build_config_details
    do
      if [[ $in_ontologies_section == 'yes' ]]
      then
        if [[ $graph_build_config_details != \ * ]]
        then
          past_ontologies_section='yes'
          in_ontologies_section='no'
          echo $graph_build_config_details >> build_configurations/$1
        fi
      elif [[ $past_ontologies_section == 'yes' ]]
      then
        echo $graph_build_config_details >> build_configurations/$1
      elif [[ $graph_build_config_details == 'ontologies:' ]]
      then
        in_ontologies_section='yes'
      fi
    done < build_configurations/$1.old
    sudo rm -r build_configurations/$1.old
    IFS="$OLD_IFS"
  fi
}

function download_ontology_file(){
  if curl --output /dev/null --silent --head --fail $1;
  then
    if [[ -e ontologies/$2 ]]
    then
      echo 'Checking for updates to' $2 'from' $1
      curl -z ontologies/$2 -o ontologies/$2 $1
      insert_scigraph_graph_ontology $1 $2
    else
      echo $2 'not found in local ontologies.'
      echo 'Downloading' $2 'from' $1
      curl -o ontologies/$2 $1
      insert_scigraph_graph_ontology $1 $2
    fi
  else
    echo 'There was an error downloading ' $2 'from' $1
  fi
}

function get_ontologies_config_file_parser(){
  declare -A configuration_array
  currentrow=0

  if [[ ! -e config.lp ]]
  then
    echo 'No config.lp file found'
    exit 1
  fi

  initialize_scigraph_build_configuration_file  $1
  filename=$1
  initialize_scigraph_run_configuration_file ${filename%.yaml}Configuration.yaml

  while read ontology_details
  do
    IFS=' '
    currentcolumn=0
    for ontology_properties in $ontology_details; do
      IFS='|'
      position='key'

      for ontology_key_value_pair in $ontology_properties; do
        #echo $position
        if [[ $position == 'key' ]]
        then
          #echo $position
          position='value'
          #echo "key"
        elif [[ $position == 'value' ]]
        then
          position='key'
          case $currentcolumn in
            0) ontology_url=$ontology_key_value_pair
               ;;
            1) ontology_file_name=$ontology_key_value_pair
               ;;
          esac
          #configuration_array[$currentcolumn, $currentrow]=$ontology_key_value_pair

          currentcolumn=$((currentcolumn+1))

          #echo "value"
        fi
        #echo "$currentcolumn, $currentrow"
      done
      IFS=' '
    done
    download_ontology_file $ontology_url $ontology_file_name
  done < config.lp
  insert_scigraph_graph_data_after_ontologies $1
  #echo  ${configuration_array[1, 0]}
  #printf '%s\n' "${configuration_array[@]}"
}

function generate_neo4j_graph(){
  if [[ ! -z $runontservice ]]
  then
    echo "Please run the deploy script with the -g option before the -r option"
    exit 1
  fi

  filename=$1
  target_directory=${filename%.yaml}
  if [[ -e build_configurations/target/$target_directory ]]
  then
    echo -e '\r\nRemoving previous graph db store folder build_configurations/target/'$target_directory
    sudo rm -r build_configurations/target/$target_directory
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
      if [[ -z "$(which screen)" ]]
      then
        echo "screen not found....installing screen"
        sudo apt-get install screen
      fi
			screen -L -S onto -d -m mvn exec:java -Dexec.mainClass="edu.sdsc.scigraph.services.MainApplication" -Dexec.args="server ../../run_configurations/$1"
			echo "The ontology server has been setup on a detached screen."
      echo "To get back to the terminal running the server process (for example if you which to stop the server) execute 'screen -r' in the vagrant box"
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

while getopts ":hug:r:ib:x:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    x)
      configuration_file=$OPTARG
      get_ontologies_config_file_parser $configuration_file
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
