#!/bin/bash

usage="$(basename "$0") [-h] [-t TARGET_FOLDER] [-p PULL_SECRET] [-r RESULTS] [-b BUNDLE]

where:
    -h  show this help text
    -t  folder on target host to which assets are copied
    -p  pull-secret file path
    -r  path to junit results folder (optional)
    -b  path to a custom microshift bundle (optional)"

# first : is for invalid option ?, then t: is for flag t that takes an argument, etc.
while getopts ":ht:p:r:b:" arg; do
  case $arg in
    h) echo "$usage"; exit;;
    t) TARGET_FOLDER=$OPTARG;;
    p) PULL_SECRET=$OPTARG;;
    r) RESULTS_PATH=$OPTARG;;
    b) BUNDLE=$OPTARG;;
    \?) printf "invalid option: -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
  esac
done

# mandatory arguments
if [ ! "${TARGET_FOLDER}" ] || [ ! "${PULL_SECRET}" ]; then
  echo "arguments -t and -p must be provided"
  echo "$usage" >&2; exit 1
fi

setupMicroshift() {
    crc config set preset microshift
    crc config set network-mode user
    if [[ -n "${BUNDLE}" ]]; then
        crc config set bundle ${BUNDLE} 
    fi
    crc config view
    crc setup
    crc start -p ${PULL_SECRET}

    # eval $(crc oc-env) didn't work for some reason
    export PATH="${HOME}/.crc/bin/oc:${PATH}"
    echo ${PATH}
}

setupMicroshift

# Prepare to run e2e
export KUBECONFIG=${HOME}/.kube/config
echo ${KUBECONFIG}

# Run e2e
rm -r ${RESULTS_PATH}; mkdir ${RESULTS_PATH}
echo ${RESULTS_PATH}

export PATH="${PATH}:${HOME}/${TARGET_FOLDER}"
echo ${PATH}

echo "running tests..."
ms-backend-e2e run -v 2 --provider=none -f ${TARGET_FOLDER}/suite.txt -o e2e.log --junit-dir ${RESULTS_PATH}
