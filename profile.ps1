$newPath = @(
  "$env:PROGRAMFILES\Git\cmd"
  "$env:PROGRAMFILES\Vim\vim82"
) -join ";"

$env:PATH = $newPath + ';' + $env:PATH

# "PS " のプレフィックスを消す
function prompt {
  $(get-location) + "> "
}