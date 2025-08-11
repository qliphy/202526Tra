#!/bin/bash

[ -e HIG-RunIISummer20UL18MiniAODv2-WHGG0-test ] && >&2 echo 'Error: HIG-RunIISummer20UL18MiniAODv2-WHGG0-test exists' && exit 1
mkdir HIG-RunIISummer20UL18MiniAODv2-WHGG0-test
cp x509run x509up HIG-RunIISummer20UL18MiniAODv2-WHGG0-wrapper.sh HIG-RunIISummer20UL18MiniAODv2-WHGG0.sh HIG-RunIISummer20UL18wmLHEGEN-WHGG0 HIG-RunIISummer20UL18DIGIPremix-02315.patch patch_premix_inputs.py HIG-RunIISummer20UL18MiniAODv2-WHGG0-test/
cd HIG-RunIISummer20UL18MiniAODv2-WHGG0-test

# HIG-RunIISummer20UL18MiniAODv2-WHGG0.sh <fragment> <nevent> <nthread> <seed>
./x509run x509up HIG-RunIISummer20UL18MiniAODv2-WHGG0-wrapper.sh HIG-RunIISummer20UL18wmLHEGEN-WHGG0 10 1 0 2>&1 | tee HIG-RunIISummer20UL18MiniAODv2-WHGG0-test.log
