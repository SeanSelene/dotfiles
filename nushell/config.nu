$env.config = {
    show_banner: false
    buffer_editor: nvim
    shell_integration: {
        osc133: false #("WEZTERM_PANE" not-in $env)
    },
    hooks: {
        env_change: {
            PWD: [
                {
                    if ((executable fnm) and ([.nvmrc .node-version package.json] | path exists | any {|i| $i})) {
                        try {
                            fnm use --silent-if-unchanged
                        }
                    }
                }
            ]
        }
    }
}

# starship 提示符
if (executable starship) {
    use ~/.cache/starship/init.nu
}

# 开关代理
def get_proxy_addr [] {
    if $is_wsl {ip route show | grep -i default | awk '{ print $3}'} else {"127.0.0.1"}
}
def --env pon [port = "7897", addr?:string] {
    let addr = if $addr == null {get_proxy_addr} else {$addr}
    let h_proxy = $"http://($addr):($port)/"
    let s_proxy = $"socks5://($addr):($port)/"
    $env.http_proxy = $h_proxy
    $env.https_proxy = $h_proxy
    $env.all_proxy = $s_proxy
    git config --global http.proxy $h_proxy
    git config --global https.proxy $h_proxy
    npm config set proxy $h_proxy
    echo $"proxy set to: ($addr): ($port)"
}
def --env poff [] {
    if "http_proxy" in $env {
        hide-env http_proxy
    }
    if "https_proxy" in $env {
        hide-env https_proxy
    }
    if "all_proxy" in $env {
        hide-env all_proxy
    }
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    npm config delete proxy
    echo "proxy disabled"
}

# open specific dir in neovide
def gvi [
    path?: string, # path to open
    --wsl (-w) # open dir in wsl
] {
    if (executable neovide) {
        if $wsl {
            wsl zsh -lic 'node --version'
            neovide --wsl -- --cmd $'cd ($path)'
        } else {
            neovide -- --cmd $'cd ($path)'
        }
    } else {
        print 'neovide not found'
    }
}

# A wrapper for Yazi to provide the ability to change the cwd.
def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -fp $tmp
}


# 命令别名
alias ga = git add
alias gaa = git add --all
alias ga. = git add .
# git commit
alias gc = git commit
alias gcm = git commit --message
# git status
alias gs = git status
alias gss = git status --short
# git stash
alias gsh = git stash
alias gshu = git stash --include-untracked
alias gshi = git stash --keep-index
# git checkout
alias gct = git checkout

alias vi = nvim
alias lg = lazygit

if (executable zed) {
    $env.EDITOR = 'zed'
}

source ~/.zoxide.nu
