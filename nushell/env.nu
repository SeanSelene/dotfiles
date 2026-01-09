def executable [cmd: string] {
  (which $cmd | length) > 0
}

def scoop-app-dir [app: string]: nothing -> string {
    let app_list = which $app
    if not ($app_list | is-empty) {
      let app_path = $app_list.0.path
      if $app_path =~ "shims" {
        $app_path | str replace -r "shims.*$" $"apps\\($app)\\current\\"
      } else {
          ""
      }
    }
}

let host_name = (sys host).name
let is_linux = $host_name =~ "Linux"
let is_wsl = $is_linux and ((sys host).kernel_version =~ "WSL")
let is_win = $host_name =~ "Windows"

# convenient to judge whether a program is launched by nu
$env.IS_NU = "1"

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


# rust
if ($"($nu.home-path)/.cargo/bin" not-in ($env.PATH | split row (char esep))) {
    $env.PATH = ($env.PATH | prepend $"($nu.home-path)/.cargo/bin")
}

# bun
if ($"($nu.home-path)/.bun/bin" | path exists) {
    let bun_path = $"($nu.home-path)/.bun/bin"
    let list = $env.PATH | split row (char esep)
    $env.PATH = $list | append $bun_path
}

# /usr/local/bin
if ("/usr/local/bin" | path exists) {
    let list = $env.PATH | split row (char esep)
    $env.PATH = $list | append "/usr/local/bin"
}

# claude code
if ($is_win and ('~/.local/bin' | path exists)) {
    $env.PATH = ($env.PATH | prepend ~/.local/bin)
    let git_path = scoop-app-dir git
    if not ($git_path | is-empty) {
        $env.CLAUDE_CODE_GIT_BASH_PATH = $"($git_path)bin\\bash.exe"
    }
}


# starship
if (executable starship) {
  mkdir ~/.cache/starship
  starship init nu | save -f ~/.cache/starship/init.nu
}

# yazi
if $is_win and (executable yazi) {
  let git_path = scoop-app-dir git
  if not ($git_path | is-empty) {
      $env.YAZI_FILE_ONE = $"($git_path)usr\\bin\\file.exe"
  }
}
