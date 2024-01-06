-- init.lua
local game_core = require("nvim-typing-game.core.game")
local ui_popup = require("nvim-typing-game.ui.popup")

local text_popup

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
    text_popup:unmount()  -- 現在のテキストポップアップを閉じる
    text_popup = ui_popup.show_text_popup(game_core.get_current_line(), game_core.get_registered_words())
  else
    print("Incorrect input, try again.")
  end

  -- 新しい入力ボックスを表示 (カスタムコンポーネントを使用)
  ui_popup.show_input_popup(M.on_input_submit, M.on_input_change)
end


function M.on_input_change(value)
  -- 以下、通常の処理
  game_core.increment_keystroke_count()
  local new_count = game_core.get_keystroke_count()
  ui_popup.update_counter_display(new_count)
  local correct_answer = game_core.get_current_highlighted_line() -- 現在の正しい答えを取得
  -- ここで位置文字ごとにcorrect_answerをsplitして合ってるかの確認を行う
  if value ~= correct_answer then
    -- エラー処理
    -- game_core.increment_error_count() -- エラーカウントを増やす
    -- その他のエラーに関する処理
  end
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
  local lines
  -- コマンドから呼び出す場合は、引数にargsが含まれるため
  -- argsが存在するか否かで分岐をしている。
  if test_lines.args then
    lines = vim.api.nvim_buf_get_lines(0, vim.api.nvim_win_get_cursor(0)[1] - 1, -1, false)
  else
    lines = test_lines
  end
  game_core.init_game(lines)
  text_popup = ui_popup.show_text_popup(game_core.get_current_line(), lines)
  ui_popup.show_input_popup(M.on_input_submit, M.on_input_change)

  -- この後ここにcore/gameからkeystroke取得してuiに動的表示してデバッグする
  local count = game_core.get_keystroke_count()
  ui_popup.show_counter(count)

  vim.schedule(function()
    game_core.set_keystroke_count(0)
  end)
end

function M.get_score()

end

function M.get_grade()

end

return M
