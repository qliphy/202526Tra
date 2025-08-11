#!/bin/bash

# Binds for singularity containers
# Mount /afs, /eos, /cvmfs, /etc/grid-security for xrootd
export APPTAINER_BINDPATH='/afs,/cvmfs,/cvmfs/grid.cern.ch/etc/grid-security:/etc/grid-security,/eos,/etc/pki/ca-trust,/run/user,/var/run/user'

# Make file executable
chmod +x HIG-RunIISummer20UL18MiniAODv2-WHGG0.sh

if [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el7:amd64" ]; then
  CONTAINER_NAME="el7:amd64"
elif [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el7:x86_64" ]; then
  CONTAINER_NAME="el7:x86_64"
else
  echo "Could not find amd64 or x86_64 for el7"
  exit 1
fi
# Run in singularity container
export SINGULARITY_CACHEDIR="/tmp/$(whoami)/singularity"
singularity run --home $PWD:$PWD /cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/$CONTAINER_NAME $(echo $(pwd)/HIG-RunIISummer20UL18MiniAODv2-WHGG0.sh) "$@"
