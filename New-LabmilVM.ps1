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

<#
.DESCRIPTION
Creates a hyper-v vm in C:\VM
.EXAMPLE
PS C:\> .\New-LabmilVM.ps1 -Name "DC01"
Creates a new hyper-v VM with the default switch
.NOTES
Author: Emil Larsson - 2021-12-18
#>
[CmdletBinding()]
param (
    [string]$Name
)

$null = New-Item ENV:\HYPERMIL_V -Value 'C:\VM' -ErrorAction SilentlyContinue
$labmilFolders = "ISO", "DRIVE", "TEMP"
$labmilFolders | ForEach-Object {
    if ( -not (Test-Path "$env:HYPERMIL_V\$_") ) {
        $null = New-Item "$env:HYPERMIL_V\$_" -ItemType Directory
    }
}

$labMilReadme = "$env:HYPERMIL_V\README.md"
if ( -not ( Test-Path $labMilReadme ) ) {
    $readmeparams = @{
        ItemType    = 'File'
        Value       = "# PLACE ISO IN .\ISO`n- Will grab the first iso, so place only one in the ISO folder`n- will only create and start the VM, for ultimate lab-age"
        Name        = 'README.md'
        Path        = "$Env:HYPERMIL_V"
        ErrorAction = 'SilentlyContinue'
    }
    $null = New-Item @readmeparams
}

# Checks if name already exists
$VMCheck = Get-VM DC01
if ($VMCheck.Name -eq $Name) {
    $NotSupportedException = New-Object -TypeName NotSupportedException -ArgumentList "The VM-Name provided already exists on the system."
    Write-Error -Exception $NotSupportedException -Category NotImplemented -ErrorAction Stop
}

# Create VM
try {
    $labMilVMParams = @{
        Name               = $Name
        MemoryStartUpBytes = 1GB
        NewVHDPath         = "$env:HYPERMIL_V\DRIVE\$Name.vhdx"
        NewVHDSizeBytes    = 40GB
        SwitchName         = 'Default Switch'
    }
    New-VM @labMilVMParams | Select-Object Name, Status, Version
}
catch {
    Write-Error $error[0]
}

# Add Iso
$Iso = (Get-Item $env:HYPERMIL_V\ISO\*.iso | Select-Object -First 1).FullName
if ($Iso) {
    Add-VMDvdDrive -VMName $Name -Path $Iso
}
else {
    Write-Warning "No iso attached to VM. $("$env:HYPERMIL_V\ISO\") seems not to have an .iso file in it. "
}

# Start VM
Start-VM $Name -Verbose
