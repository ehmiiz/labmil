# Labmil - easy hyper-v labbing

## The gist of it

- Labmil is a module to easily spin up a standard set of hyper-v machines
- The idea being that the servers are just named, started and iso attached
- The roles has to be installed by hand and all configs manually (or with own script) to increase the labbing!
- Manily used for my own purpose to lab with Windows Server from the initial set-up
- I would recommend AutomatedLab instead of this if you are in a hurry

## Requires

- Hyper-V enabled
- an iso-file

## Step-by-Step
1. git clone https://github.com/ehmiiz/labmil.git - cd labmil
2. Initial creation:
```powershell
.\New-LabmilVM.ps1 -Name "DC01" -IsoPath "C:\Users\Example\WinServ2022.iso
```
3. The -IsoPath param is only needed on first-time-use. It will copy the iso to C:\VM\ISO, and re-use it
4. To create multiple VMs after first use:
```powershell
"DC2","DC3","DC4","PKI-ROOT","PKI-ISSUER" | Foreach-Object { .\New-LabmilVM.ps1 -Name $_ }
```