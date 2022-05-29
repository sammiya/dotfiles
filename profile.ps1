$newPath = @(
  "$env:PROGRAMFILES\Git\cmd"
  "$env:PROGRAMFILES\Vim\vim82"
  "$env:USERPROFILE\.pyenv\pyenv-win\bin"
  "$env:USERPROFILE\.pyenv\pyenv-win\shims"
) -join ";"

$env:PATH = $newPath + ';' + $env:PATH

# "PS " のプレフィックスを消す
function prompt {
  $(get-location).toString() + "> "
}
