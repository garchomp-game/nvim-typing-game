-- main module file
local module = require("nvim-typing-game.module")

---@class Config
---@field opt string Your config option
local config = {
  opt = "Hello!",
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.hello = function()
  local message = module.my_first_function()
  local buf = vim.api.nvim_create_buf(false, true) -- 新しいバッファを作成
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"Hello World!"}) -- バッファにテキストを設定

  -- フローティングウィンドウのオプション
  local opts = {
    relative = "editor",
    width = 20,
    height = 2,
    col = math.floor((vim.o.columns - 20) / 2),
    row = math.floor((vim.o.lines - 2) / 2),
    anchor = "NW",
    style = "minimal",
    border = "rounded",
  }

  -- フローティングウィンドウを開く
  vim.api.nvim_open_win(buf, true, opts)
end

return M
