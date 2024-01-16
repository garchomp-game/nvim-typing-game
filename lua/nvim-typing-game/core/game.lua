---@class Game
---@field game_lines string[]|table|string ゲームで使用されるテキスト行の配列
---@field current_line number 現在のテキスト行番号
---@field is_over boolean ゲームが終了したかどうか
---@field before_buffer number ゲーム開始前のバッファID
---@field error_count number エラーの総数
---@field keystroke_count number キーストロークの総数
---@field start_time number ゲーム開始時のタイムスタンプ
---@field char_error_count number 文字入力エラーの総数
---@field result_score number ゲームのスコア
local Game = {}
Game.__index = Game

---@return Game
function Game.new()
  local self = setmetatable({}, Game)
    self.game_lines = nil
    self.current_line = 1
    self.is_over = false
    self.before_buffer = 1
    self.error_count = 0
    self.keystroke_count = 0
    self.start_time = 0
    self.char_error_count = 0
    self.result_score = 0
  return self
end

--- `active_before_buffer` は、ゲーム終了後に元のバッファに戻るためのローカル関数です。
---この関数は、現在のウィンドウに対して、ゲーム開始前のバッファを設定します。
function Game:active_before_buffer()
  -- ゲーム終了後に元のバッファに戻す
  local current_window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(current_window, self.before_buffer)
end

--- `calculate_game_duration` は、ゲームの所要時間を計算するローカル関数です。
---この関数は、ゲームの開始時刻と終了時刻の差（秒単位）を計算し、所要時間を返します。
---@return number ゲームの所要時間（秒単位）。
function Game:calculate_game_duration()
  local end_time = os.time()  -- ゲーム終了時のタイムスタンプ
  return end_time - self.start_time  -- 経過時間（秒単位）
end

--- `calculate_score` は、ゲームのスコアを計算するローカル関数です。
---この関数は、キーストローク数、エラー数、およびゲームの所要時間を考慮して、スコアを計算します。
function Game:calculate_score()
  local time = self:calculate_game_duration()  -- ゲームの所要時間を取得（秒単位）

  -- 時間が0の場合、スコアを0とする
  if time == 0 then
    return 0
  end

  local keystrokes_per_minute = (self.keystroke_count / time) * 60  -- 1分あたりの打数

  -- 1ミスあたり5点を減点
  local score = keystrokes_per_minute - (self.char_error_count * 5)

  -- スコアがマイナスにならないようにする
  return math.max(0, score)
end

--- `init_game` 関数は、ゲームを初期化し、開始状態に設定します。
---@param lines string|table|string[] ゲームで使用するテキスト行の配列。
function Game:init_game(lines)
  print("check lines1")
  require("util").print_table(lines)
  print("end check lines1")
  self.before_buffer = vim.api.nvim_get_current_buf()
  self.game_lines = lines
  self.current_line = 1
  self.is_over = false
  self.start_time = os.time()
end

--- `process_input` 関数は、ユーザーの入力を処理し、それが正しいかどうかを判定します。
---@param line string ユーザーによって入力されたテキスト行。
---@return boolean is_correct 入力が正しい場合は true、そうでない場合は false。
function Game:process_input(line)
  local is_correct = false -- 正誤判定用のフラグ
  if self.game_lines == nil then
    return is_correct
  end
  if self.game_lines[self.current_line] == line then
    self.current_line = self.current_line + 1
    is_correct = true
    if self.current_line > #self.game_lines then
      self.is_over = true
      self:calculate_score()
      self:active_before_buffer()
    end
  else
    self.error_count = self.error_count + 1
  end
  return is_correct
end

--- `increment_keystroke_count` 関数は、キーストロークのカウントを1増やします。
function Game:increment_keystroke_count()
  self.keystroke_count = self.keystroke_count + 1
  -- UI更新関数を呼び出す
  local ui_popup = require("nvim-typing-game.ui.popup").new()
  ui_popup:update_counter_display(self.keystroke_count)
end

--- `is_game_over` 関数は、ゲームが終了しているかどうかを判定します。
---@return boolean ゲームが終了している場合は true、そうでない場合は false。
function Game:is_game_over()
  return self.is_over
  -- ゲームの終了条件は、現在の行がゲーム行数よりも1大きいとき
  -- return current_line > #game_lines
end

--- `increment_char_error_count` 関数は、文字入力エラーのカウントを1増やします。
function Game:increment_char_error_count()
  self.char_error_count = self.char_error_count + 1
end

--- `get_current_highlighted_line` 関数は、指定された行番号のテキスト行を取得します。
---@param line_number number 取得する行の番号。
---@return string 指定された行のテキスト。
function Game:get_current_highlighted_line(line_number)
  if self.game_lines ~= nil then
    return self.game_lines[line_number]
  else
    return ""
  end
end

--- `get_keystroke_count` 関数は、現在のキーストロークカウントを返します。
---@return number 現在のキーストロークカウント。
function Game:get_keystroke_count()
  return self.keystroke_count
end

--- `set_keystroke_count` 関数は、キーストロークカウントを指定した値に設定します。
---@param value number 新しいキーストロークカウントの値。
function Game:set_keystroke_count(value)
  self.keystroke_count = value
end

--- `get_registered_words` 関数は、ゲームで使用されるテキスト行の配列を返します。
---@return string|table|string[]|nil テキスト行の配列。
function Game:get_registered_words()
  print("check lines2")
  print(self.game_lines)
  print("end check lines2")
  return self.game_lines
end

--- `get_game_lines_length` 関数は、ゲームで使用されるテキスト行の総数を返します。
---@return number テキスト行の総数。
function Game:get_game_lines_length()
  return #self.game_lines
end

--- `get_current_line` 関数は、現在の行番号を返します。
---@return number 現在の行番号。
function Game:get_current_line()
  return self.current_line
end

--- `get_error_count` 関数は、エラーの総数を返します。
---@return number エラーの総数。
function Game:get_error_count()
  return self.error_count
end

--- `get_char_error_count` 関数は、エラーの総数を返します。
---@return number 文字単位のエラーの総数。
function Game:get_char_error_count()
  return self.char_error_count
end

--- `get_score` 関数は、リザルトのスコアを返します。
---@return number リザルトのスコア
function Game:get_score()
  return self.result_score
end

--- `get_grade` 関数は、リザルトのスコアに基づいてグレードの情報を返します。
--- @return string 対応するグレードの文字列
function Game:get_grade()
  local score = self:get_score()

  if score >= 260 then
    return "S"
  elseif score >= 220 then
    return "A"
  elseif score >= 170 then
    return "B"
  elseif score >= 120 then
    return "C"
  elseif score >= 70 then
    return "D"
  else
    return "F"
  end
end

return Game
