#!/bin/bash
# Modified by: <lyazj@github.com>

if [ $# != 4 ]; then
    >&2 echo "usage: $(basename $0) <fragment> <nevent> <nthread> <seed>"
    exit 1
fi
FRAGMENT=$1
NEVENT=$2
NTHREAD=$3
SEED=$4

set -ev
FRAGMENT_NAME="$(basename "${FRAGMENT}")"
FRAGMENT="$(readlink -f "${FRAGMENT}")"
OUTDIR=/eos/user/${USER:0:1}/${USER}/MiniAODStore/V0/2018/MC/WplusH_HToQQ_WToLNu_M-125_TuneCP5_13TeV-powheg-pythia8/HIG-RunIISummer20UL18MiniAODv2-WHGG0
OUTFILE="${OUTDIR}/${SEED}.root"
xrdfs eosuser.cern.ch mkdir -p "${OUTDIR}"
echo "Output file: ${OUTFILE}"

! xrdfs eosuser.cern.ch stat "${OUTFILE}" 2>/dev/null  # early stop on name collision
voms-proxy-info  # early stop on proxy error
source /cvmfs/cms.cern.ch/cmsset_default.sh

# setup scram environment with fragment installed
scram_setup() {
    # scram configuration
    # NOTE: external environment variable ${SCRAM_ARCH} is required to be set
    if [ $# != 2 ]; then
        >&2 echo "usage: $(basename $0) <arch> <rlse>"
        exit 1
    fi
    export SCRAM_ARCH=$1
    export SCRAM_RLSE=$2

    # fragment configuration
    # NOTE: the procedure sets global environment variable ${FRAGMENT_COPY}
    local PYTHON_DIR=Configuration/GenProduction/python  # w.r.t. ${SCRAM_RLSE}/src
    FRAGMENT_COPY=${PYTHON_DIR}/${FRAGMENT_NAME}_copy.py

    # scram creation
    if [ -r ${SCRAM_RLSE}/src ] ; then
        echo release ${SCRAM_RLSE} already exists
    else
        scram p CMSSW ${SCRAM_RLSE}
    fi

    # scram initialization
    # NOTE: copy fragment in before building scram
    pushd ${SCRAM_RLSE}/src  # ******************** $PWD changed ********************
    eval `scram runtime -sh`
    mkdir -p ${PYTHON_DIR}
    sed s/__TO_BE_REPLACED_NEVENT/${NEVENT}/g "${FRAGMENT}" > ${FRAGMENT_COPY}
    scram b -j ${NTHREAD}
    popd  # ******************** $PWD restored ********************
}

# 0_HIG-RunIISummer20UL18wmLHEGEN-02820.sh
scram_setup slc7_amd64_gcc700 CMSSW_10_6_28
cmsDriver.py ${FRAGMENT_COPY} --python_filename HIG-RunIISummer20UL18wmLHEGEN-02820.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --fileout file:HIG-RunIISummer20UL18wmLHEGEN-02820.root --conditions 106X_upgrade2018_realistic_v4 --beamspot Realistic25ns13TeVEarly2018Collision --customise_commands 'process.RandomNumberGeneratorService.externalLHEProducer.initialSeed=int('${SEED}')+1\nprocess.source.numberEventsInLuminosityBlock=cms.untracked.uint32(100)' --step LHE,GEN --geometry DB:Extended --era Run2_2018 --mc -n ${NEVENT} --nThreads ${NTHREAD}

# 1_HIG-RunIISummer20UL18SIM-02334.sh
scram_setup slc7_amd64_gcc700 CMSSW_10_6_17_patch1
cmsDriver.py --python_filename HIG-RunIISummer20UL18SIM-02334.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:HIG-RunIISummer20UL18SIM-02334.root --conditions 106X_upgrade2018_realistic_v11_L1v1 --beamspot Realistic25ns13TeVEarly2018Collision --step SIM --geometry DB:Extended --filein file:HIG-RunIISummer20UL18wmLHEGEN-02820.root --era Run2_2018 --runUnscheduled --mc -n ${NEVENT} --nThreads ${NTHREAD}

# 2_HIG-RunIISummer20UL18DIGIPremix-02315.sh
scram_setup slc7_amd64_gcc700 CMSSW_10_6_17_patch1
cmsDriver.py --python_filename HIG-RunIISummer20UL18DIGIPremix-02315.py --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI --fileout file:HIG-RunIISummer20UL18DIGIPremix-02315.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL18_106X_upgrade2018_realistic_v11_L1v1-v2/PREMIX" --conditions 106X_upgrade2018_realistic_v11_L1v1 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --geometry DB:Extended --filein file:HIG-RunIISummer20UL18SIM-02334.root --datamix PreMix --era Run2_2018 --runUnscheduled --mc -n ${NEVENT} --nThreads ${NTHREAD} --no_exec
./patch_premix_inputs.py HIG-RunIISummer20UL18DIGIPremix-02315.py HIG-RunIISummer20UL18DIGIPremix-02315.patch
cmsRun HIG-RunIISummer20UL18DIGIPremix-02315.py

# 3_HIG-RunIISummer20UL18HLT-02334.sh
scram_setup slc7_amd64_gcc700 CMSSW_10_2_16_UL
cmsDriver.py --python_filename HIG-RunIISummer20UL18HLT-02334.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:HIG-RunIISummer20UL18HLT-02334.root --conditions 102X_upgrade2018_realistic_v15 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:2018v32 --geometry DB:Extended --filein file:HIG-RunIISummer20UL18DIGIPremix-02315.root --era Run2_2018 --mc -n ${NEVENT} --nThreads ${NTHREAD}

# 4_HIG-RunIISummer20UL18RECO-02334.sh
scram_setup slc7_amd64_gcc700 CMSSW_10_6_17_patch1
cmsDriver.py --python_filename HIG-RunIISummer20UL18RECO-02334.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:HIG-RunIISummer20UL18RECO-02334.root --conditions 106X_upgrade2018_realistic_v11_L1v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --geometry DB:Extended --filein file:HIG-RunIISummer20UL18HLT-02334.root --era Run2_2018 --runUnscheduled --mc -n ${NEVENT} --nThreads ${NTHREAD}

# 5_HIG-RunIISummer20UL18MiniAODv2-02334.sh
scram_setup slc7_amd64_gcc700 CMSSW_10_6_20
cmsDriver.py --python_filename HIG-RunIISummer20UL18MiniAODv2-02334.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:HIG-RunIISummer20UL18MiniAODv2-02334.root --conditions 106X_upgrade2018_realistic_v16_L1v1 --step PAT --procModifiers run2_miniAOD_UL --geometry DB:Extended --filein file:HIG-RunIISummer20UL18RECO-02334.root --era Run2_2018 --runUnscheduled --mc -n ${NEVENT} --nThreads ${NTHREAD}

# output
xrdcp HIG-RunIISummer20UL18MiniAODv2-02334.root root://eosuser.cern.ch/"${OUTFILE}"
