---@class GameRunner
---@field game Game ゲームのロジックを扱うGameクラスのインスタンス
---@field ui_popup UiPopup ユーザーインターフェースの表示を扱うUiPopupクラスのインスタンス
---@field text_popup table テキスト表示用のポップアップオブジェクト
local GameRunner = {}
GameRunner.__index = GameRunner

function GameRunner.new()
  local self = setmetatable({}, GameRunner)
  self.game = require("nvim-typing-game.core.game").new()
  self.ui_popup = require("nvim-typing-game.ui.popup").new()
  self.text_popup = nil
  return self
end

--- `on_input_submit` 関数は、ユーザーが入力を送信したときに呼び出される関数です。
---この関数は、入力された値を処理し、ゲームの状態を更新します。
---@param value string ユーザーによって入力された文字列。
function GameRunner:on_input_submit(value)
  local is_correct = self.game:process_input(value)

  if self.game:is_game_over() then
    if self.text_popup then
      self.text_popup:unmount()  -- テキストポップアップを閉じる
      self.ui_popup:unmount_counter()
      self.game:calculate_score()
      self.ui_popup:show_result_popup(
        self.game:get_score(),
        self.game:get_grade()
      )
    end
    print("Game Over!")
    return
  end

  if is_correct then
    if self.text_popup then
      self.text_popup:unmount()  -- 現在のテキストポップアップを閉じる
    end
    local words = self.game:get_registered_words()
    if words ~= nil and type(words) == "table" then
      self.text_popup = self.ui_popup:show_text_popup(self.game:get_current_line(), words)
    end
  else
    print("Incorrect input, try again.")
  end

  self.ui_popup:show_input_popup(
    function(submit_value) self:on_input_submit(submit_value) end,
    function(change_value) self:on_input_change(change_value) end
  )
end

--- `on_input_change` 関数は、ユーザーの入力が変更されるたびに呼び出される関数です。
---この関数は、入力された値を監視し、キーストロークのカウントを更新します。
---@param value string ユーザーによって入力された現在の文字列。
function GameRunner:on_input_change(value)
  -- 既存のキーストロークカウント処理...
  self.game:increment_keystroke_count()
  local new_count = self.game:get_keystroke_count()
  self.ui_popup:update_counter_display(new_count)
  local current_line = self.game:get_current_line()

  -- 現在の正しい答えを取得
  local correct_answer = self.game:get_current_highlighted_line(current_line)
  local correct_chars = {}
  for char in string.gmatch(correct_answer, ".") do
    table.insert(correct_chars, char)
  end

  local text_buf = self.text_popup.bufnr
  local error_detected = false

  -- ユーザーの入力と正解を比較し、エラーを検出した場合にハイライトを適用
  for i = 1, #value do
    if value:sub(i, i) ~= correct_chars[i] then
      self.game:increment_char_error_count()

      -- エラー検出のためにフラグをセット
      error_detected = true

      -- ハイライトを適用する行と列を決定
      local error_line = current_line - 1  -- テキストバッファの行は0から始まる
      local error_col = i - 1  -- 列も0から始まる

      -- エラーがある文字にハイライトを適用
      vim.api.nvim_buf_add_highlight(text_buf, -1, "ErrorMsg", error_line, error_col, error_col + 1)
      break
    end
  end

  -- エラーが検出されなかった場合、以前のハイライトをクリア
  if not error_detected then
    local current_line_buf = current_line - 1
    vim.api.nvim_buf_clear_namespace(text_buf, -1, current_line_buf, current_line_buf + 1)
  end
end

--- ゲームの進行状況を取得する関数
--- @return table ゲームの進行状況を示すテーブル。
--- 戻り値のテーブルのフィールド:
--- `current_line` (number): 現在の行番号。
--- `total_lines` (number): 全行数。
--- `completed` (boolean): ゲームが完了したかどうか。
function GameRunner:get_progress()
  return {
    current_line = self.game:get_current_line(),
    total_lines = self.game:get_game_lines_length(),  -- 全体の行数
    completed = self.game:is_game_over(),
  }
end

--- `start_game` 関数は、ゲームを開始するために呼び出されます。
---この関数は、ゲームの初期設定を行い、必要なUIコンポーネントを表示します。
---@param test_lines table|string テスト用の行またはコマンドライン引数。
function GameRunner:start_game(test_lines)
  local lines
  -- コマンドから呼び出す場合は、引数にargsが含まれるため
  -- argsが存在するか否かで分岐をしている。
  if test_lines.args then
    lines = vim.api.nvim_buf_get_lines(0, vim.api.nvim_win_get_cursor(0)[1] - 1, -1, false)
  else
    lines = test_lines
  end
  self.game:init_game(lines)
  if lines ~= nil then
    self.text_popup = self.ui_popup:show_text_popup(self.game:get_current_line(), lines)
  end
  self.ui_popup:show_input_popup(
    function(submit_value) self:on_input_submit(submit_value) end,
    function(change_value) self:on_input_change(change_value) end
  )

  -- この後ここにcore/gameからkeystroke取得してuiに動的表示してデバッグする
  local count = self.game:get_keystroke_count()
  self.ui_popup:show_counter(count)

  vim.schedule(function()
    self.game:set_keystroke_count(0)
  end)
end

--- `get_registered_words` 関数は、Gameクラスのget_registered_wordsを返します。
--- @return string[]|table|string|nil get_registered_words Gameクラスのget_registered_words
function GameRunner:get_registered_words()
  return self.game:get_registered_words()
end

--- `get_current_highlighted_line` 関数は、Gameクラスのget_current_highlighted_lineを返します
--- @return string get_current_highlighted_line 指定された行のテキスト 
function GameRunner:get_current_highlighted_line(value)
  return self.game:get_current_highlighted_line(value)
end

--- `is_game_over` は、Gameクラスのis_game_overを返します。
--- @return boolean is_game_over game overだったらtrue
function GameRunner:is_game_over()
  return self.game:is_game_over()
end

--- `get_error_count` は、Gameクラスのget_error_countを返します
--- @return number get_error_count Gameクラスのget_error_count
function GameRunner:get_error_count()
  return self.game:get_error_count()
end

--- `get_score` は、Gameクラスのget_scoreを返します
--- @return number get_score Gameクラスのget_score
function GameRunner:get_score()
  return self.game:get_score()
end

--- `get_grade` は、Gameクラスのget_gradeを返します
--- @return string get_grade Gameクラスのget_grade
function GameRunner:get_grade()
  return self.game:get_grade()
end

--- `get_show_result_popup` は、リザルト画面の情報を取得します。
--- @return table show_result_popup リザルト画面の情報
function GameRunner:get_show_result_popup()
  -- ui_popupモジュールのshow_result_popup関数を呼び出して、
  -- リザルト画面を表示する
  return self.ui_popup:show_result_popup(self.game:get_score(), self.game:get_grade())
end

return GameRunner
