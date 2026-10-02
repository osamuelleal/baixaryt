# Builds BaixarYT in release mode and installs it for the current user,
# with Start Menu and Desktop shortcuts. Run again to update; -Uninstall removes it.
#   powershell -ExecutionPolicy Bypass -File install.ps1 [-Uninstall]
param([switch]$Uninstall)
$ErrorActionPreference = 'Stop'

$dest = "$env:LOCALAPPDATA\Programs\BaixarYT"
$shortcuts = @(
  "$([Environment]::GetFolderPath('Programs'))\BaixarYT.lnk",
  "$([Environment]::GetFolderPath('Desktop'))\BaixarYT.lnk"
)

if (Get-Process baixaryt -ErrorAction SilentlyContinue) { throw 'Close BaixarYT before installing.' }

if ($Uninstall) {
  Remove-Item $dest -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item $shortcuts -Force -ErrorAction SilentlyContinue
  'BaixarYT uninstalled.'
  return
}

Push-Location $PSScriptRoot
try {
  flutter build windows --release
  if ($LASTEXITCODE) { throw 'Build failed.' }
} finally { Pop-Location }

# Per-user folder (no admin) so yt-dlp can update itself in bin\.
robocopy "$PSScriptRoot\build\windows\x64\runner\Release" $dest /MIR /NFL /NDL /NJH /NJS | Out-Null
if ($LASTEXITCODE -ge 8) { throw "Copy failed (robocopy exit $LASTEXITCODE)." }

$shell = New-Object -ComObject WScript.Shell
foreach ($path in $shortcuts) {
  $link = $shell.CreateShortcut($path)
  $link.TargetPath = "$dest\baixaryt.exe"
  $link.WorkingDirectory = $dest
  $link.Save()
}
"BaixarYT installed to $dest"
