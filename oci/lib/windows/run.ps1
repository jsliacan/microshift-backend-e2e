param(
    # [Parameter(Mandatory,HelpMessage='openshift version to be tested')]
    # $openshiftVersion,
    [Parameter(Mandatory,HelpMessage='folder on target host where assets are copied')]
    $targetFolder,
    [Parameter(HelpMessage='junit results path')]
    $junitResultsPath="$targetFolder/junit",
    [Parameter(HelpMessage='junit filename')]
    $junitFilename="microshift-e2e.xml",
    [Parameter(Mandatory,HelpMessage='pull secret file')]
    $pullSecretFile,
    [Parameter(HelpMessage='bundle path if custom bundle to be used')]
    $bundlePath
)

function Setup-Microshift {
    crc config set preset microshift
    if($bundlePath){
        crc config set bundle $bundlePath
    }
    crc setup
    crc start -p $pullSecretFile
    
    # SSH expands a terminal but due to how crc recognized the shell 
    # it does not recognize powershell but other process so we force it
    $env:SHELL="powershell"
    & crc oc-env | Invoke-Expression
}

# Setup the backend
Setup-Microshift

# Prepare to run e2e
mv $targetFolder/ms-backend-e2e $targetFolder/ms-backend-e2e.exe # needs to be *.exe to be executable on Windows
$env:KUBECONFIG="$env:HOME\.kube\config"

# Run e2e
New-Item -Path $junitResultsPath -ItemType Directory
$env:PATH="$env:PATH;$env:HOME\$targetFolder;"
ms-backend-e2e.exe run -v 2 --provider=none -f $targetFolder/suite.txt -o e2e.log --junit-dir $junitResultsPath
mv $junitResultsPath/junit*.xml $junitResultsPath/$junitFilename

# Clenaup cluster
crc stop 
crc cleanup
