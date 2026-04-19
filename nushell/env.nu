# =====================
# helper functions
# =====================

def executable [cmd: string] {
    which $cmd | is-not-empty
}

def scoop-app-dir [app: string]: nothing -> string {
    let scoop_path = which scoop
    if ($scoop_path | is-empty) {
        error make $"Could not find scoop"
    }
    let scoop_root = $scoop_path | get path.0 | str replace -r '\\shims\\.*$' ''
    let app_dir = $scoop_root | path join apps $app current
    if not ($app_dir | path exists) {
        error make $"Could not find ($app)"
    }
    $app_dir
}

def --env add-to-path [bin: string] {
    let bin = $bin | path expand
    if ($bin | path exists) and ($bin not-in $env.PATH) {
        $env.PATH = ($env.PATH | append $bin)
    }
}

def setup-apps [] {
    if (executable zoxide) {
        zoxide init nushell | save -f ~/.zoxide.nu
    }
    if (executable starship) {
        mkdir ~/.cache/starship
        starship init nu | save -f ~/.cache/starship/init.nu
    }
}

# =====================
# environment dectection
# =====================

let host_name = (sys host).name
let is_linux = $host_name =~ "Linux"
let is_wsl = $is_linux and ((sys host).kernel_version =~ "WSL")
let is_win = $host_name =~ "Windows"



# =====================
# PATH
# =====================
add-to-path ~/.cargo/bin    # Rust
add-to-path ~/.bun/bin      # Bun
add-to-path /usr/local/bin
add-to-path ~/.local/bin



# =====================
# environment setup for windows
# =====================
if $is_win {
    try {
        let git_path = scoop-app-dir git
        if (executable claude) {
            $env.CLAUDE_CODE_GIT_BASH_PATH = $git_path | path join "bin" "bash.exe"
        }
        if (executable yazi) {
            $env.YAZI_FILE_ONE = $git_path | path join "usr" "bin" "file.exe"
        }
    }
}

# =====================
# tools
# =====================

# fnm
if (executable fnm) {
    fnm env --json | from json | load-env
    $env.PATH = $env.PATH | prepend $env.FNM_MULTISHELL_PATH
    $env.FNM_NODE_DIST_MIRROR = "https://mirrors.ustc.edu.cn/node/"
}


# Ensure that the zoxide initialization file exists
if not ("~/.zoxide.nu" | path expand | path exists) {
    touch ~/.zoxide.nu
}
