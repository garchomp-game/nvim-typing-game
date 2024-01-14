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

  -- ゲームが終了しているか確認
  if self.game:is_game_over() then
    self.text_popup:unmount()  -- テキストポップアップを閉じる
    print("Game Over!")
    return  -- ここで関数を終了させる
  end

  if is_correct then
    self.text_popup:unmount()  -- 現在のテキストポップアップを閉じる
    local words = self.game:get_registered_words()
    if words ~= nil and type(words) == "table" then
      text_popup = self.ui_popup:show_text_popup(self.game:get_current_line(), words)
    end
  else
    print("Incorrect input, try again.")
  end

  -- 新しい入力ボックスを表示 (カスタムコンポーネントを使用)
  self.ui_popup:show_input_popup(GameRunner.on_input_submit, GameRunner.on_input_change)
end

--- `on_input_change` 関数は、ユーザーの入力が変更されるたびに呼び出される関数です。
---この関数は、入力された値を監視し、キーストロークのカウントを更新します。
---@param value string ユーザーによって入力された現在の文字列。
function GameRunner:on_input_change(value)
  -- キーストロークカウントをインクリメント
  self.game:increment_keystroke_count()
  local new_count = self.game:get_keystroke_count()
  self.ui_popup:update_counter_display(new_count)
  local current_line = self.game:get_current_line()

  -- 現在の正しい答えを取得
  local correct_answer = self.game:get_current_highlighted_line(current_line)
  -- 正解の文字列を1文字ずつに分割
  local correct_chars = {}
  -- 後でデバッグで使う関数
  for char in string.gmatch(correct_answer, ".") do
    table.insert(correct_chars, char)
  end

  -- ユーザーの入力と正解を比較
  for i = 1, #value do
    if value:sub(i, i) ~= correct_chars[i] then
      -- エラーカウントを増やす
      self.game:increment_char_error_count()
      break -- 1つのエラーを見つけたらループを抜ける
    end
  end
end

--- ゲームの進行状況を取得する関数
--- @return table any ゲームの進行状況を示すテーブル。
--- 戻り値のテーブルのフィールド:
--- `current_line` (number): 現在の行番号。
--- `total_lines` (number): 全行数。
--- `completed` (boolean): ゲームが完了したかどうか。
function GameRunner:get_progress()
  return {
    current_line = self.game:get_current_line(),
    total_lines = self.game:get_game_lines_length(),  -- 全体の行数
    completed = self.game:is_game_over()
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
    text_popup = self.ui_popup:show_text_popup(self.game:get_current_line(), lines)
  end
  self.ui_popup:show_input_popup(GameRunner.on_input_submit, GameRunner.on_input_change)

  -- この後ここにcore/gameからkeystroke取得してuiに動的表示してデバッグする
  local count = self.game:get_keystroke_count()
  self.ui_popup:show_counter(count)

  vim.schedule(function()
    self.game:set_keystroke_count(0)
  end)
end

return GameRunner
