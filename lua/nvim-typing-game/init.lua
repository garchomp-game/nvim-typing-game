-- init.lua
local game_core = require("nvim-typing-game.core.game")
local ui_popup = require("nvim-typing-game.ui.popup")

local input_popup
local text_popup
local current_line = 1

local M = {}

function M.on_input_submit(value)
  local is_correct = game_core.process_input(value)
  if is_correct then
    current_line = current_line + 1
    text_popup:unmount()  -- 現在のテキストポップアップを閉じる
    text_popup = ui_popup.show_text_popup(current_line, game_core.get_registered_words())
  end

  if game_core.is_game_over() then
    input_popup:unmount()
    text_popup:unmount()
    -- ゲーム終了時の処理
  end
end


function M.start_game()
  local lines = vim.api.nvim_buf_get_lines(0, vim.api.nvim_win_get_cursor(0)[1] - 1, -1, false)
  game_core.init_game(lines)
  text_popup = ui_popup.show_text_popup(current_line, lines)
  input_popup = ui_popup.show_input_popup(on_input_submit)
end

return M
