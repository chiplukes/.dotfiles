-- lua/core/util.lua
local M = {}

-- Reload a module during development: require('core.util').R('module.name')
function M.R(name)
  package.loaded[name] = nil
  return require(name)
end

function M.safe_require(name)
  local ok, m = pcall(require, name)
  return ok and m or nil
end

return M
