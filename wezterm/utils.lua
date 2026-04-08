local wezterm = require("wezterm")

local M = {}

function M.get_git_shell_path()
  local gitc = os.getenv("gitc")
  if gitc ~= nil then
    local res = string.gsub(gitc, "\\usr\\bin\\?$", "\\bin\\bash.exe")
    return res
  end
  return nil
end

function M.win_executable(cmd)
  local handle = io.popen("where " .. cmd)
  if handle ~= nil then
    local s = handle:read("*a")
    handle:close()
    return s ~= ""
  end
  return false
end

function M.get_os()
  local target = wezterm.target_triple
  if target:find("windows") then
    return "windows"
  elseif target:find("apple") then
    return "macos"
  else
    return "linux"
  end
end

return M
