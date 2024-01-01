-- init.lua
local game_core = require("nvim-typing-game.core.game")
local ui_popup = require("nvim-typing-game.ui.popup")

local input_popup
local text_popup

local function on_input_submit(value)
  game_core.process_input(value)
  if game_core.is_game_over() then
    input_popup:unmount()
    text_popup:unmount()
    -- ここでゲーム終了時の処理を行う
  end
end

local M = {}

function M.start_game()
  local lines = vim.api.nvim_buf_get_lines(0, vim.api.nvim_win_get_cursor(0)[1] - 1, -1, false)
  game_core.init_game(lines)
  text_popup = ui_popup.show_text_popup(lines)
  input_popup = ui_popup.show_input_popup(on_input_submit)
end

return M
