param(
  [string]$signClientUser,
  [string]$signClientPassword,
  [string]$artifactSearchPattern,
  [string]$appSettingsType,
  [string]$appSettingsFilePath,
  [string]$appSettings,
  [string]$fileListType,
  [string]$fileListFilePath,
  [string]$fileList,
  [string]$projectName,
  [string]$projectDescription,
  [string]$url
)

Write-Verbose 'Entering task.ps1'
Write-Verbose 'Current Working Directory is $cwd'

# See if we have the Client Credentials available

if([string]::IsNullOrEmpty($signClientUser)){
  throw "Client User not found, not signing packages"
}
if([string]::IsNullOrEmpty($signClientPassword)){
  throw "Client Password not found, not signing packages"
}

# Setup Variables we need to pass into the sign client tool
if (-not ([string]::IsNullOrEmpty($appSettings)) -and $appSettingsType -eq "inline") {
  $appSettingsFilePath = "$env:AGENT_WORKFOLDER\appsettings$env:BUILD_BUILDNUMBER.json"
  Write-Host "Creating $appSettingsFilePath"
  Out-File -FilePath $appSettingsFilePath -InputObject $appSettings -Encoding ASCII
}
elseif(-not (Test-Path $appSettingsFilePath -PathType Leaf) -and $appSettingsType -eq "file") {
  throw "You must provide either an appsettings file path, or inline appsettings."
}
elseif ($appSettingsType -eq "inline") {
  throw "You must provide inline content for the appSettings.json, or select a filepath for a file in your repository"
}

if (-not ([string]::IsNullOrEmpty($fileList)) -and $fileListType -eq "inline") {
  $fileListFilePath = "$env:AGENT_WORKFOLDER\filelist$env:BUILD_BUILDNUMBER.txt"
  Write-Host "Creating $fileListFilePath"
  Out-File -FilePath $fileListFilePath -InputObject $fileList -Encoding ASCII
}
elseif(-not (Test-Path $fileListFilePath -PathType Leaf) -and $fileListType -eq "file") {
  throw "You must provide either a file list file path, or inline file list."
}
elseif ($fileListType -eq "inline") {
  throw "You must provide a signing filter"
}

$nupkgs = Get-ChildItem $artifactSearchPattern -recurse | Select-Object -ExpandProperty FullName

Write-Host "Found " + $nupkgs.Count + " packages"

if($nupkgs.Count -gt 0) {
  Write-Host "Installing SignClient DotNet Tool"
  dotnet tool install --tool-path . SignClient

  Write-Verbose "Project Name: $projectName"
  Write-Verbose "Project Description: $projectDescription"
  Write-Verbose "Project Url $url"
  
  foreach ($nupkg in $nupkgs) {
    Write-Host "Submitting $nupkg for signing"

    $args = 'sign --config "' + $appSettingsFilePath + '" --input "' + $nupkg + '" --filter "' + $fileListFilePath + '" --user "' + $signClientUser + '" --secret "' + $signClientPassword + '" --name "' + $projectName + '" --description "' + $projectDescription + '" --descriptionUrl "' + $url + '"'

    Write-Verbose 'sign --config "' + $appSettingsFilePath + '" --input "' + $nupkg + '" --filter "' + $fileListFilePath + '" --user "*****************" --secret "*************" --name "' + $projectName + '" --description "' + $projectDescription + '" --descriptionUrl "' + $url + '"'

    .\SignClient $args
    Write-Host "Finished signing $nupkg"
  }

  Write-Host "Sign-package complete"
}
else {
  Write-Host "No packages found"
}
