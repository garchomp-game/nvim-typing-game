---core/game.lua
local M = {}

local game_lines = nil
local current_line = 1
local is_over = false
local before_buffer
local error_count = 0
local keystroke_count = 0
local start_time
local char_error_count = 0
local result_score = 0

--- `active_before_buffer` は、ゲーム終了後に元のバッファに戻るためのローカル関数です。
---この関数は、現在のウィンドウに対して、ゲーム開始前のバッファを設定します。
local active_before_buffer = function()
  -- ゲーム終了後に元のバッファに戻す
  local current_window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(current_window, before_buffer)
end

--- `calculate_game_duration` は、ゲームの所要時間を計算するローカル関数です。
---この関数は、ゲームの開始時刻と終了時刻の差（秒単位）を計算し、所要時間を返します。
---@return number ゲームの所要時間（秒単位）。
local calculate_game_duration = function()
  local end_time = os.time()  -- ゲーム終了時のタイムスタンプ
  return end_time - start_time  -- 経過時間（秒単位）
end

--- `calculate_score` は、ゲームのスコアを計算するローカル関数です。
---この関数は、キーストローク数、エラー数、およびゲームの所要時間を考慮して、スコアを計算します。
local calculate_score = function()
  local time = calculate_game_duration()  -- ゲームの所要時間を取得（秒単位）

  -- 時間が0の場合、スコアを0とする
  if time == 0 then
    return 0
  end

  local keystrokes_per_minute = (keystroke_count / time) * 60  -- 1分あたりの打数

  -- 1ミスあたり5点を減点
  local score = keystrokes_per_minute - (char_error_count * 5)

  -- スコアがマイナスにならないようにする
  return math.max(0, score)
end

--- `init_game` 関数は、ゲームを初期化し、開始状態に設定します。
---@param lines string|table|string[] ゲームで使用するテキスト行の配列。
function M.init_game(lines)
  before_buffer = vim.api.nvim_get_current_buf()
  game_lines = lines
  current_line = 1
  is_over = false
  start_time = os.time()
end

--- `process_input` 関数は、ユーザーの入力を処理し、それが正しいかどうかを判定します。
---@param line string ユーザーによって入力されたテキスト行。
---@return boolean 入力が正しい場合は true、そうでない場合は false。
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

--- `increment_keystroke_count` 関数は、キーストロークのカウントを1増やします。
function M.increment_keystroke_count()
  keystroke_count = keystroke_count + 1
  -- UI更新関数を呼び出す
  require('nvim-typing-game.ui.popup').update_counter_display(keystroke_count)
end

--- `is_game_over` 関数は、ゲームが終了しているかどうかを判定します。
---@return boolean ゲームが終了している場合は true、そうでない場合は false。
function M.is_game_over()
  return is_over
  -- ゲームの終了条件は、現在の行がゲーム行数よりも1大きいとき
  -- return current_line > #game_lines
end

--- `increment_char_error_count` 関数は、文字入力エラーのカウントを1増やします。
function M.increment_char_error_count()
  char_error_count = char_error_count + 1
end

--- `get_current_highlighted_line` 関数は、指定された行番号のテキスト行を取得します。
---@param line_number number 取得する行の番号。
---@return string 指定された行のテキスト。
function M.get_current_highlighted_line(line_number)
  if game_lines ~= nil then
    return game_lines[line_number]
  else
    return ""
  end
end

--- `get_keystroke_count` 関数は、現在のキーストロークカウントを返します。
---@return number 現在のキーストロークカウント。
function M.get_keystroke_count()
  return keystroke_count
end

--- `set_keystroke_count` 関数は、キーストロークカウントを指定した値に設定します。
---@param value number 新しいキーストロークカウントの値。
function M.set_keystroke_count(value)
  keystroke_count = value
end

--- `get_registered_words` 関数は、ゲームで使用されるテキスト行の配列を返します。
---@return string|table|string[]|nil テキスト行の配列。
function M.get_registered_words()
  return game_lines
end

--- `get_game_lines_length` 関数は、ゲームで使用されるテキスト行の総数を返します。
---@return number テキスト行の総数。
function M.get_game_lines_length()
  return #game_lines
end

--- `get_game_lines_length` 関数は、ゲームで使用されるテキスト行の総数を返します。
---@return number テキスト行の総数。
function M.get_current_line()
  return current_line
end

--- `get_current_line` 関数は、現在の行番号を返します。
---@return number 現在の行番号。
function M.get_error_count()
  return error_count
end

--- `get_error_count` 関数は、エラーの総数を返します。
---@return number エラーの総数。
function M.get_char_error_count()
  return char_error_count
end

--- `get_result_score` 関数は、リザルトのスコアを返します。
---@return number リザルトのスコア
function M.get_result_score()
  return result_score
end

return M
