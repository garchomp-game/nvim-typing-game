-- core/game.lua
local M = {}

local game_lines = nil
local current_line = 1
local is_over = false
local before_buffer
local error_count = 0
local keystroke_count = 0
local start_time

local active_before_buffer = function()
  -- ゲーム終了後に元のバッファに戻す
  local current_window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(current_window, before_buffer)
end

local calculate_game_duration = function()
  local end_time = os.time()  -- ゲーム終了時のタイムスタンプ
  return end_time - start_time  -- 経過時間（秒単位）
end

local calculate_score = function()
  local time = calculate_game_duration()  -- ゲームの所要時間を取得
  local basic_score = keystroke_count - error_count  -- 正確な入力数から誤入力数を引く
  local time_score = math.max(0, 100 - time)  -- 時間に基づいたスコア（例：100秒以下の場合、100から時間を引いた値）

  return basic_score + time_score  -- 基本スコアと時間スコアを合計
end

function M.init_game(lines)
  before_buffer = vim.api.nvim_get_current_buf()
  game_lines = lines
  current_line = 1
  is_over = false
  start_time = os.time()
end

function M.process_input(line)
  local is_correct = false
  if game_lines == nil then
    return is_correct
  end
  if game_lines[current_line] == line then
    current_line = current_line + 1
    is_correct = true
    if current_line > #game_lines then
      is_over = true
      calculate_score()
      active_before_buffer()
    end
  else
    error_count = error_count + 1
  end
  return is_correct
end

function M.increment_keystroke_count()
  keystroke_count = keystroke_count + 1
  -- UI更新関数を呼び出す
  require('nvim-typing-game.ui.popup').update_counter_display(keystroke_count)
end

function M.get_keystroke_count()
  return keystroke_count
end

function M.set_keystroke_count(value)
  keystroke_count = value
end

-- core/game.lua
function M.is_game_over()
  return is_over
  -- ゲームの終了条件は、現在の行がゲーム行数よりも1大きいとき
  -- return current_line > #game_lines
end

function M.get_current_highlighted_line(line_number)
  if game_lines ~= nil then
    return game_lines[line_number]
  end
end

function M.get_registered_words()
  return game_lines
end

function M.get_game_lines_length()
  return #game_lines
end
function M.get_current_line()
  return current_line
end
function M.get_error_count()
  return error_count
end

return M
