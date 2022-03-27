mkdir -f $env:USERPROFILE\Documents\WindowsPowerShell
New-Item -Force -ItemType SymbolicLink -Value $PSScriptRoot\profile.ps1 -Path $env:USERPROFILE\Documents\WindowsPowerShell
