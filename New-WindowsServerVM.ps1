<#
.SYNOPSIS
    This script will generate a Hyper-V VM
.EXAMPLE
    .\New-WindowsServerVM.ps1
.NOTES
    Author: Emil Larsson
    2021-12-09
#>


<#
    1. Create and/or verify environment var and folders
        Env:\HYPERMIL_V = C:\VM
        Env:\HYPERMIL_V\Iso
        Env:\HYPERMIL_V\VMDisks
    2. Load iso file in iso folder
    3. Create base VM using iso, standard virt switch, given name
#>
function New-WindowsServerVM {
<#
.DESCRIPTION
    Creates a hyper-v vm in C:\VM
.EXAMPLE
    PS C:\> New-WindowsSererVM -Name "DC01"
    Creates a new hyper-v VM with the default switch
.NOTES
    Author: Emil Larsson - 2021-12-18
#>
    [CmdletBinding()]
    param (
        [string]$Name
    )

    $null = New-Item ENV:\HYPERMIL_V -Value 'C:\VM' -ErrorAction SilentlyContinue
    $labmilFolders = "ISO","DRIVE","TEMP"
    $labmilFolders | ForEach-Object {
        if ( -not (Test-Path "$env:HYPERMIL_V\$_") ){
            $null = New-Item "$env:HYPERMIL_V\$_" -ItemType Directory
        }
    }
    
    $labMilReadme = "$env:HYPERMIL_V\README.md"
    if ( -not ( Test-Path $labMilReadme ) ) {
        $readmeparams = @{
            ItemType = 'File'
            Value = "# PLACE ISO IN .\ISO`n- Will grab the first iso, so place only one in the ISO folder`n- will only create and start the VM, for ultimate lab-age"
            Name = 'README.md'
            Path = "$Env:HYPERMIL_V"
            ErrorAction = 'SilentlyContinue'
        }
        $null = New-Item @readmeparams
    }

    # Create VM

    $labMilVMParams = @{
        Name = $Name
        MemoryStartUpBytes = 1GB
        NewVHDPath = "$env:HYPERMIL_V\DRIVE\$Name.vhdx"
        NewVHDSizeBytes = 40GB
        SwitchName = 'Default Switch'
    }
    New-VM @labMilVMParams

    # Add Iso
    Add-VMDvdDrive -VMName $Name -Path (Get-Item $env:HYPERMIL_V\ISO\*.iso | Select-Object -First 1).FullName

    # Start VM
    Start-VM $Name
}