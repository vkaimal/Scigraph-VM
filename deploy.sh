#!/bin/bash
echo "Hello and welcome the SciGraph-Vagrant deployment system"
usage()
{
  cat << EOF
  usage: $0 options

  This script script will clone the SciGraph repository if the SciGraph folder does not exist

  OPTIONS:
    -h  Show this message
    -u  Updates a specific branch when given an argument or updates current branch if none is given 
    -b  Deploy (checkout) a specified branch.
EOF
}

while getopts ":hub:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    u)
      echo "we will pull latest updates on current branch"
      exit 0
      ;;
    b)
      checkoutbranch=$OPTARG
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done


if [[ ! -z $checkoutbranch ]]
then
  echo "we will checkout " $checkoutbranch
else
  usage
  exit 1
fi