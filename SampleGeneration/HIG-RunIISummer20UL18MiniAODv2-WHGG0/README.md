# Generating $H \to gg$ private samples in CMS

## Usage

To begin, run the following command to generate or renew an X.509 certificate in the current directory:

```
./x509up-gen
```

1. Test the Setup

   Run the following script to verify everything works as expected:

   ```bash
   ./HIG-RunIISummer20UL18MiniAODv2-WHGG0-test.sh
   ```

2. Submit HTCondor Jobs for Large-Scale Production

   Edit HIG-RunIISummer20UL18MiniAODv2-WHGG0.txt: Fill in the Monte Carlo (MC) seeds for event generation. Each seed will produce a separate ROOT file.

   Edit HIG-RunIISummer20UL18MiniAODv2-WHGG0.jdl: Set the number of events per job. A value of 100 events per ROOT file is generally sufficient.

   Finally:

   ```bash
   condor_submit HIG-RunIISummer20UL18MiniAODv2-WHGG0.jdl
   ```

---

Contact: \<lyazj@github.com\> or \<seeson@pku.edu.cn\>
