import FWCore.ParameterSet.Config as cms

process = cms.Process("Demo")

runOnMC = True
process.load('Configuration/StandardSequences/FrontierConditions_GlobalTag_condDBv2_cff')
from Configuration.AlCa.GlobalTag import GlobalTag
if runOnMC:
   process.GlobalTag.globaltag = '106X_mcRun2_asymptotic_v3' 
elif not(runOnMC):
   process.GlobalTag.globaltag = '106X_mcRun2_asymptotic_v3'

process.load("FWCore.MessageService.MessageLogger_cfi")
process.maxEvents = cms.untracked.PSet( input = cms.untracked.int32(-1) )
process.MessageLogger.cerr.FwkReport.reportEvery = 100

process.source = cms.Source("PoolSource",
    # replace 'myfile.root' with the source file you want to use
    fileNames = cms.untracked.vstring(
        'file:/afs/cern.ch/user/q/qili/workspace/test/BTV-RunIISummer19UL16GEN-00003.root'
    )
)

process.TFileService = cms.Service('TFileService',
    fileName = cms.string("eff.root")
)


process.demo = cms.EDAnalyzer('DemoAnalyzer',
    gentag = cms.InputTag('generator'),
#    lhetag = cms.InputTag('externalLHEProducer'),
    genSrc = cms.InputTag('genParticles'),
    PtNBins = cms.int32(20),
    PtMin = cms.double(-10.),
    PtMax = cms.double(10.),
)


process.p = cms.Path(process.demo)
