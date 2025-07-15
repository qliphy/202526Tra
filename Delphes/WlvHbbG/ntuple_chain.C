/*
This macro is used to produce the ntuple.root,
storing useful informations we need

root -l examples/ntuple.C
*/

//------------------------------------------------------------------------------

double deltaPhi(const double& phi1, const double& phi2)
{
        double deltaphi = fabs(phi1 - phi2);
        if (deltaphi > 3.141592654) deltaphi = 6.283185308 - deltaphi;
        return deltaphi;
}

double deltaEta(const double& eta1, const double& eta2)
{
        double deltaeta = fabs(eta1 - eta2);
        return deltaeta;
}

double deltaR(const double& eta1, const double& phi1,
                const double& eta2, const double& phi2)
{
        double deltaphi = deltaPhi(phi1, phi2);
        double deltaeta = deltaEta(eta1, eta2);
        double deltar = sqrt(deltaphi*deltaphi + deltaeta*deltaeta);
        return deltar;
}

//------------------------------------------------------------------------------

class ExRootResult;
class ExRootTreeReader;

//------------------------------------------------------------------------------

void AnalyseEvents(ExRootTreeReader *treeReader, TString filename)
{
  // create a root file to store the variables
  TFile file(filename, "recreate");
  TTree *tree = new TTree("tree", "keep events after cuts");

  int inputNum=0;
  int event;
  int numPar;
  int pid[1200], pm1[1200], pm2[1200], pd1[1200], pd2[1200];
  double ppt[1200];
  int numJet, numvbfJet, numbJet;
  double ptBJet[99],etaBJet[99],phiBJet[99],massBJet[99];
  //double ptbj1,etabj1,phibj1,massbj1,ptbj2,etabj2,phibj2,massbj2;
  //double ptbjj,etabjj,phibjj,massbjj;
  double met, masshbb;
  int numEl, numMu, numLep;
  double ptEl[99],etaEl[99],phiEl[99],ptMu[99],etaMu[99],phiMu[99];
  int chargeEl[99],chargeMu[99];
  //double ptl1,etal1,phil1,massl1,ptl2,etal2,phil2,massl2;
  //double ptll,etall,phill,massll;
  //int chargel1,chargel2, chargell;

  //double dRll,dRjj,dRbb,dRl1j1,dRl1j2,dRl2j1,dRl2j2,dRl1b1,dRl1b2,dRl2b1,dRl2b2,dRj1b1,dRj1b2,dRj2b1,dRj2b2;

  tree->Branch("event", &event, "event/I");
  tree->Branch("numPar", &numPar, "numPar/I");
  tree->Branch("pid", &pid, "pid[numPar]/I");
  tree->Branch("pm1", &pm1, "pm1[numPar]/I");
  tree->Branch("pm2", &pm2, "pm2[numPar]/I");
  tree->Branch("pd1", &pd1, "pd1[numPar]/I");
  tree->Branch("pd2", &pd2, "pd2[numPar]/I");
  tree->Branch("ppt", &ppt, "ppt[numPar]/D");
  tree->Branch("inputNum", &inputNum, "inputNum/I");
  tree->Branch("numJet", &numJet, "numJet/I");
  tree->Branch("numbJet", &numbJet, "numbJet/I");
  tree->Branch("numEl", &numEl, "numEl/I");
  tree->Branch("numMu", &numMu, "numMu/I");
  tree->Branch("numLep", &numLep, "numLep/I");
  tree->Branch("ptBJet", &ptBJet, "ptBJet[numbJet]/D");
  tree->Branch("etaBJet", &etaBJet, "etaBJet[numbJet]/D");
  tree->Branch("phiBJet", &phiBJet, "phiBJet[numbJet]/D");
  tree->Branch("massBJet", &massBJet, "massBJet[numbJet]/D");
  tree->Branch("met", &met, "met/D");
  tree->Branch("ptEl", &ptEl, "ptEl[numEl]/D");
  tree->Branch("etaEl", &etaEl, "etaEl[numEl]/D");
  tree->Branch("phiEl", &phiEl, "phiEl[numEl]/D");
  tree->Branch("chargeEl", &chargeEl, "chargeEl[numEl]/I");
  tree->Branch("ptMu", &ptMu, "ptMu[numMu]/D");
  tree->Branch("etaMu", &etaMu, "etaMu[numMu]/D");
  tree->Branch("phiMu", &phiMu, "phiMu[numMu]/D");
  tree->Branch("chargeMu", &chargeMu, "chargeMu[numMu]/I");
  tree->Branch("masshbb", &masshbb, "masshbb/D");

  TClonesArray *branchEvent = treeReader->UseBranch("Event");
  TClonesArray *branchParticle = treeReader->UseBranch("Particle");
  TClonesArray *branchElectron = treeReader->UseBranch("Electron");
  TClonesArray *branchMuon = treeReader->UseBranch("Muon");
  TClonesArray *branchJet = treeReader->UseBranch("Jet");
  TClonesArray *branchMET = treeReader->UseBranch("MissingET");

  Long64_t numberOfEntries = treeReader->GetEntries();
  inputNum = numberOfEntries;

  cout << "** Chain contains " << numberOfEntries << " events" << endl;

  for(int count=0; count < numberOfEntries; count++)
  {
      //initiate branch members
      event=-1; numJet=-1; numvbfJet=0; numbJet=0;
      met=-99;
      numEl=-1; numMu=-1; numLep=-1; numPar=-1;
      for(int i=0; i<99; i++)
      {
          ptBJet[i]=-99;etaBJet[i]=-99;phiBJet[i]=-99;massBJet[i]=-99;
	  ptEl[i]=-99;etaEl[i]=-99;phiEl[i]=-99;chargeEl[i]=-99;
          ptMu[i]=-99;etaMu[i]=-99;phiMu[i]=-99;chargeMu[i]=-99;
      }
      for(int i=0; i<1200; i++)
      {
          pid[i]=-1000;pm1[i]=-1000;pm2[i]=-1000;pd1[i]=-1000;pd2[i]=-1000; ppt[i]=-1000;
      }

      treeReader->ReadEntry(count) ;
      //********************************************************************
      //CUT1: at least 4 jets, 2 VBF jets and 2 b jets, with pt>25, |eta_vbfj|<4.7, |eta_bj|<2.5, deltaEta_vbfj1j2>2.5, 
      //CUT2: met cut >30      
      //CUT3--Good leptons: 2 leptons with pt>20, eta<2.5 and same sign
      GenParticle* Par[1200];
      numPar = branchParticle->GetEntries();
      if(!numPar)continue;
      for(int i=0; i<numPar; i++)
      {
        Par[i]=(GenParticle*)branchParticle->At(i); 
        pid[i]=Par[i]->PID;
        pm1[i]=Par[i]->M1;
        pm2[i]=Par[i]->M2;
        pd1[i]=Par[i]->D1;
        pd2[i]=Par[i]->D2;
        ppt[i]=Par[i]->PT;
      }

      numJet = branchJet->GetEntries();
      if(numJet<2)continue;

      MissingET* Met = (MissingET *) branchMET->At(0);
      met=Met->MET;
      if(met<30)continue;

      Event* ev = (Event*)branchEvent->At(0);
      event=ev->Number;

      numEl=branchElectron->GetEntries();
      numMu=branchMuon->GetEntries();
      if(numMu+numEl!=1)continue;

      Jet* pJet[1200]; // access to Jet Collection
      double btagJet[1200]; // btag value of jet in Jet Collection
      for(int i=0, j=0, k=0; i<numJet; i++)
      {
          if(branchJet->At(i))
       	  {
	      pJet[i]=(Jet*)branchJet->At(i);
              btagJet[i]=pJet[i]->BTag;

              if( (btagJet[i] & (1 << 0)) && pJet[i]->PT>25 && fabs(pJet[i]->Eta)<2.5 )
	      {
		  ptBJet[k]=pJet[i]->PT;
                  etaBJet[k]=pJet[i]->Eta;
                  phiBJet[k]=pJet[i]->Phi;
                  massBJet[k]=pJet[i]->Mass;
		  numbJet++;k++;
	      }
	  }
      } // end of i<numJet

      if(numbJet<1)continue;

      TLorentzVector bj[2], bjj;

      bj[0].SetPtEtaPhiM(ptBJet[0],etaBJet[0],phiBJet[0],massBJet[0]);
      bj[1].SetPtEtaPhiM(ptBJet[1],etaBJet[1],phiBJet[1],massBJet[1]);
      bjj=bj[0]+bj[1];
      masshbb=bjj.M();
 
     //********************************************************************
      //CUT3--Good leptons:  
      Electron* E[99] ;
      Muon* M[99] ;
      float EMass = 0.000511 ;
      float MMass = 0.105000 ;
      int mark1=0,mark2=0;


      for(int i=0; i<numEl; i++)
      {
         E[i]=(Electron*)branchElectron->At(i); 
         if(E[i]->PT>20 && fabs(E[i]->Eta)<2.5)
         {
             ptEl[mark1]=E[i]->PT;
             etaEl[mark1]=E[i]->Eta;
             phiEl[mark1]=E[i]->Phi;
             chargeEl[mark1]=E[i]->Charge;
	     mark1++;
         }
      }
      for(int j=0; j<numMu; j++)
      {
         M[j]=(Muon*)branchMuon->At(j);
         if(M[j]->PT>20 && fabs(M[j]->Eta)<2.5)
         {
             ptMu[mark2]=M[j]->PT;
             etaMu[mark2]=M[j]->Eta;
             phiMu[mark2]=M[j]->Phi;
             chargeMu[mark2]=M[j]->Charge;
             mark2++;
   	 }
      }

      numLep=mark1+mark2;

      tree->Fill();
  } // end of chain loop
  //tree->Print();
  file.Write();
}

//------------------------------------------------------------------------------

void ntuple_chain()
{
  gSystem->Load("/home/qliphy/Desktop/MG5_aMC_v2.4.2/MG5_aMC_v2_4_2/Delphes/libDelphes");
  //THStack *stack;
  // access to 0-600 HT bin files
  TChain *chain = new TChain("Delphes");
  chain->Add("tag_1_delphes_events.root");
  ExRootTreeReader *treeReader1 = new ExRootTreeReader(chain);
  ExRootResult *result1 = new ExRootResult();
  AnalyseEvents(treeReader1, "14TeVNoPU_ntuple_sig1.root");

  cout << "** Exiting..." << endl;

  delete result1;
  delete treeReader1;
  delete chain;
}

//------------------------------------------------------------------------------
