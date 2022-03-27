$newPath = @(
  "$env:PROGRAMFILES\Git\cmd"
) -join ";"

$env:PATH = $newPath + ';' + $env:PATH