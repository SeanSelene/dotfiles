local wezterm = require("wezterm")

local wsl_domains = wezterm.default_wsl_domains()

for _, dom in ipairs(wsl_domains) do
  dom.default_cwd = "~"
  dom.default_prog = { "nu" }
end

local sys = {
  default_prog = { "nu" },
  wsl_domains = wsl_domains,
}

-- if #wsl_domains > 0 then
--   sys.default_domain = wsl_domains[1].name
-- end

if string.match(wezterm.target_triple, "darwin") then
  sys.set_environment_variables = {
    PATH = "/opt/homebrew/bin:" .. os.getenv("PATH"),
  }
end

return sys
