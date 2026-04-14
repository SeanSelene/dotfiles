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

let host_name = (sys host).name
let is_linux = $host_name =~ "Linux"
let is_wsl = $is_linux and ((sys host).kernel_version =~ "WSL")
let is_win = $host_name =~ "Windows"

# fnm
if (executable fnm) {
    fnm env --json | from json | load-env
    let list = $env.PATH | split row (char esep)
    if $is_win {
        $env.PATH = $list | append $env.FNM_MULTISHELL_PATH
    } else {
        $env.PATH = $list | where $it !~ 'fnm' | prepend $'($env.FNM_MULTISHELL_PATH)/bin'
    }
    $env.FNM_NODE_DIST_MIRROR = "https://mirrors.ustc.edu.cn/node/"
}
def add-to-path [bin: string] {
    let bin = $bin | path expand
    # 检查路径是否存在，且当前 PATH 中是否尚未包含该路径
    if ($bin | path exists) and ($bin not-in $env.PATH) {
        $env.PATH = ($env.PATH | append $bin)
    }
}

# rust
add-to-path ~/.cargo/bin
# bun
add-to-path ~/.bun/bin

add-to-path /usr/local/bin
add-to-path ~/.local/bin

# claude code
if ($is_win and (executable claude)) {
    try {
        let git_path = scoop-app-dir git
        $env.CLAUDE_CODE_GIT_BASH_PATH = $git_path | path join "bin" "bash.exe"
    }
}

def setup-apps [] {
    if (executable zoxide) {
        zoxide init nushell | save -f ~/.zoxide.nu
    }
    # starship
    if (executable starship) {
        mkdir ~/.cache/starship
        starship init nu | save -f ~/.cache/starship/init.nu
    }
}



# yazi
if $is_win and (executable yazi) {
    try {
        let git_path = scoop-app-dir git
        $env.YAZI_FILE_ONE = $git_path | path join "usr" "bin" "file.exe"
    }
}

touch ~/.zoxide.nu
