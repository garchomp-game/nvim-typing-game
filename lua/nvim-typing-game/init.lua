-- init.lua
local game_core = require("nvim-typing-game.core.game")
local ui_popup = require("nvim-typing-game.ui.popup")

local text_popup
local current_line = 1

local M = {}


-- init.lua の on_input_submit 関数
function M.on_input_submit(value)
  local is_correct = game_core.process_input(value)

  -- ゲームが終了しているか確認
  if game_core.is_game_over() then
    text_popup:unmount()  -- テキストポップアップを閉じる
    print("Game Over!")
    return  -- ここで関数を終了させる
  end

  if is_correct then
    current_line = current_line + 1
    text_popup:unmount()  -- 現在のテキストポップアップを閉じる
    text_popup = ui_popup.show_text_popup(current_line, game_core.get_registered_words())
  else
    print("Incorrect input, try again.")
  end

  -- 新しい入力ボックスを表示 (カスタムコンポーネントを使用)
  ui_popup.show_input_popup(M.on_input_submit)
end

function M.get_progress()
  return {
    current_line = game_core.get_current_line(),
    total_lines = game_core.get_game_lines_length(),  -- 全体の行数
    completed = game_core.is_game_over()
  }
end

function M.get_error_count()
  return game_core.get_error_count()
end

function M.start_game(test_lines)
  local lines = test_lines or vim.api.nvim_buf_get_lines(0, vim.api.nvim_win_get_cursor(0)[1] - 1, -1, false)
  game_core.init_game(lines)
  text_popup = ui_popup.show_text_popup(current_line, lines)
  -- カスタム入力コンポーネントの呼び出し
  ui_popup.show_input_popup(M.on_input_submit)
end

function M.get_score()

end

function M.get_grade()

end

return M
