---@class GameRunner
---@field game Game ゲームのロジックを扱うGameクラスのインスタンス
---@field ui_popup UiPopup ユーザーインターフェースの表示を扱うUiPopupクラスのインスタンス
---@field text_popup table テキスト表示用のポップアップオブジェクト

local GameClass = require("nvim-typing-game.core.game")
game = GameClass.new()

local UiPopup = require("nvim-typing-game.ui.popup").new()
local ui_popup = UiPopup.new()

local GameRunner = {}
GameRunner.__index = GameRunner

function GameRunner.new()
  local self = setmetatable({}, GameRunner)
  self.text_popup = nil
  return self
end

--- `on_input_submit` 関数は、ユーザーが入力を送信したときに呼び出される関数です。
---この関数は、入力された値を処理し、ゲームの状態を更新します。
---@param value string ユーザーによって入力された文字列。
function GameRunner:on_input_submit(value)
  local is_correct = game:process_input(value)

  -- ゲームが終了しているか確認
  if game:is_game_over() then
    self.text_popup:unmount()  -- テキストポップアップを閉じる
    print("Game Over!")
    return  -- ここで関数を終了させる
  end

  if is_correct then
    self.text_popup:unmount()  -- 現在のテキストポップアップを閉じる
    local words = game:get_registered_words()
    if words ~= nil and type(words) == "table" then
      text_popup = ui_popup:show_text_popup(game:get_current_line(), words)
    end
  else
    print("Incorrect input, try again.")
  end

  -- 新しい入力ボックスを表示 (カスタムコンポーネントを使用)
  ui_popup:show_input_popup(GameRunner.on_input_submit, GameRunner.on_input_change)
end

--- `on_input_change` 関数は、ユーザーの入力が変更されるたびに呼び出される関数です。
---この関数は、入力された値を監視し、キーストロークのカウントを更新します。
---@param value string ユーザーによって入力された現在の文字列。
function GameRunner:on_input_change(value)
  -- キーストロークカウントをインクリメント
  game:increment_keystroke_count()
  local new_count = game:get_keystroke_count()
  ui_popup:update_counter_display(new_count)
  local current_line = game:get_current_line()

  -- 現在の正しい答えを取得
  local correct_answer = game:get_current_highlighted_line(current_line)
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
      game:increment_char_error_count()
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
    current_line = game:get_current_line(),
    total_lines = game:get_game_lines_length(),  -- 全体の行数
    completed = game:is_game_over(),
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
  game:init_game(lines)
  if lines ~= nil then
    text_popup = ui_popup:show_text_popup(game:get_current_line(), lines)
  end
  ui_popup:show_input_popup(GameRunner.on_input_submit, GameRunner.on_input_change)

  -- この後ここにcore/gameからkeystroke取得してuiに動的表示してデバッグする
  local count = game:get_keystroke_count()
  ui_popup:show_counter(count)

  vim.schedule(function()
    game:set_keystroke_count(0)
  end)
end

return GameRunner
