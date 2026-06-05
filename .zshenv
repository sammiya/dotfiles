# Keep mise shims ahead of inherited direct install paths in non-interactive shells.
if [[ -n "$HOME" ]]; then
    _mise_shims="$HOME/.local/share/mise/shims"
    path=(${path:#$HOME/.local/share/mise/installs/*})

    if [[ -d "$_mise_shims" ]]; then
        path=("$_mise_shims" ${path:#$_mise_shims})
    fi

    unset _mise_shims
    export PATH
fi
