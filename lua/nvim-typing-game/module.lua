---@class CustomModule
local M = {}

---@return string
M.my_first_function = function()
  local message = "hello world!"
  vim.api.nvim_echo({{message, "None"}}, true, {})
  return message
end

return M
