# 予め管理者権限で以下を実行しておく:
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

mkdir -f $env:USERPROFILE\Documents\WindowsPowerShell
New-Item -Force -ItemType SymbolicLink -Value $PSScriptRoot\profile.ps1 -Path $env:USERPROFILE\Documents\WindowsPowerShell\profile.ps1
New-Item -Force -ItemType SymbolicLink -Value $PSScriptRoot\settings.json -Path $env:APPDATA\Code\User\settings.json
New-Item -Force -ItemType SymbolicLink -Value $PSScriptRoot\.gitconfig -Path $env:USERPROFILE\.gitconfig
New-Item -Force -ItemType SymbolicLink -Value $PSScriptRoot\.gitignore_global -Path $env:USERPROFILE\.gitignore_global

# winget export で出力されるファイルを利用することも考えたが、
# VSCode が出力されなかったりよくわからない挙動があるのでふつうにコマンドを列挙

winget install vim.vim
rm $env:PUBLIC\Desktop\gVim*.lnk
winget install git.git
winget install Microsoft.VisualStudioCode
winget install Discord.Discord
winget install Google.Chrome
winget install Docker.DockerDesktop

cat extensions.txt | % { code --install-extension $_ }

wsl --install
