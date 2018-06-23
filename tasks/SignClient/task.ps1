Param(
  [string]$signClientUser,
  [string]$signClientSecret,
  [string]$artifactSearchPattern,
  [string]$appSettingsFilePath,
  [string]$fileListFilePath,
  [string]$appSettings,
  [string]$fileList,
  [string]$projectName,
  [string]$projectDescription,
  [string]$url
)

$currentDirectory = split-path $MyInvocation.MyCommand.Definition

# See if we have the ClientSecret available
if([string]::IsNullOrEmpty($signClientSecret)){
    Write-Host "Client Secret not found, not signing packages"
    return;
}

# Setup Variables we need to pass into the sign client tool

if (-not ([string]::IsNullOrEmpty($appSettings))) {
  Write-Host "Creating appsettings.json"
  $appSettingsFilePath = "$currentDirectory\appsettings.json"
  Out-File -FilePath $appSettingsFilePath -InputObject $appSettings -Encoding ASCII
}
elseif(-not (Test-Path $appSettingsFilePath -PathType Leaf)) {
  throw "You must provide either an appsettings file path, or inline appsettings."
}

if (-not ([string]::IsNullOrEmpty($fileList))) {
  $fileListFilePath = "$currentDirectory\filelist.txt"
  Out-File -FilePath $fileListFilePath -InputObject $fileList -Encoding ASCII
}
elseif(-not (Test-Path $fileListFilePath -PathType Leaf)) {
  throw "You must provide either a file list file path, or inline file list."
}

$nupkgs = Get-ChildItem $artifactSearchPattern -recurse | Select-Object -ExpandProperty FullName

Write-Host "Installing SignClient DotNet Tool"
dotnet tool install --tool-path . SignClient

foreach ($nupkg in $nupkgs){
   Write-Host "Submitting $nupkg for signing"

    .\SignClient 'sign' -c $appSettings -i $nupkg -f $fileList -r $signClientUser -s $signClientSecret -n $projectName -d $projectDescription -u $url

    Write-Host "Finished signing $nupkg"
}

Write-Host "Sign-package complete"
