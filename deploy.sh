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
    -i  Gets information about available branches
EOF
}

function update_scigraph(){
  
  if [[ -d 'SciGraph' ]]
  then
    cd SciGraph
    git pull https://github.com/SciCrunch/SciGraph.git
    if [[ $? -eq 0 ]]
    then
      echo "running maven install"
      mvn -DskipTests -DskipITs install
      exit 0
    else
      echo "No git repository was found in the SciGraph folder"
      echo "Delete the SciGraph folder and run deply with the -u option"
      exit 1
    fi
  else
    echo 'SciGraph directory not found'
    git clone https://github.com/SciCrunch/SciGraph.git
    cd SciGraph
    echo "running maven install"
    mvn -DskipTests -DskipITs install
    exit 0
  fi
}

function checkout_scigraph_branch(){
  if [[ -d 'SciGraph' ]]
  then
    cd SciGraph
    git checkout $1
    if [[ $? -eq 0 ]]
    then
      echo "running maven install"
      mvn -DskipTests -DskipITs install
      exit 0
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

while getopts ":huib:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    u)
      update_scigraph
      ;;
    b)
      checkoutbranch=$OPTARG
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


if [[ ! -z $checkoutbranch ]]
then
  echo "we will checkout and refactor all dependencies" $checkoutbranch
  checkout_scigraph_branch $checkoutbranch
else
  usage
  exit 1
fi