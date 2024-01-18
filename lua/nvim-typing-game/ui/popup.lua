local nui_input = require("nui.input")
local Popup = require("nui.popup")

---@class UiPopup
---@field lines table バッファの情報を保存
---@field count_buf number カウンター表示用のバッファ番号
---@field count_popup table カウンター表示用のポップアップオブジェクト
local UiPopup = {}
UiPopup.__index = UiPopup

function UiPopup.new()
  local self = setmetatable({}, UiPopup)
  self.lines = nil  -- グローバルまたはモジュールスコープでバッファ番号を保存
  self.count_buf = nil
  self.count_popup = nil
  return self
end

--- `calculate_popup_position` は、ポップアップの位置を計算するローカル関数です。
---これは、ポップアップを画面の中央に配置するための行と列の位置を計算します。
---@param popup_height number ポップアップの高さ。
---@return table ポップアップの位置を示す `{ row = number, col = number }` 形式のテーブル。
local function calculate_popup_position(popup_height)
  local win_height = vim.api.nvim_win_get_height(0)
  local center_row = math.floor(win_height / 2)
  local position_row = center_row - math.floor(popup_height / 2)
  return { row = position_row, col = "50%" }
end

--- `show_input_popup` 関数は、入力を受け付けるポップアップを表示します。
---@param on_input_submit function ユーザーが入力を送信した際に呼び出される関数。
---@param on_input_change function ユーザーの入力が変更された際に呼び出される関数。
---@return table NUIポップアップオブジェクト。
function UiPopup:show_input_popup(on_input_submit, on_input_change)
  local input_popup = nui_input({
    position = calculate_popup_position(10),
    size = { width = 50 },
    border = {
      style = "rounded",
      text = {
        top = "[入力エリア]",  -- ボーダー上部にラベルを設定
        top_align = "center"
      }
    },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:Teal" },
  }, {
      prompt = "",
      on_submit = on_input_submit,
      on_change = on_input_change
    })

  input_popup:mount()
  return input_popup
end

--- `show_text_popup` 関数は、テキストを表示するポップアップを作成し、表示します。
---@param current_line number 現在の行番号。
---@param text_lines string|table|string[] テキストの行を含むテーブル。
---@return table NUIポップアップオブジェクト。
function UiPopup:show_text_popup(current_line, text_lines)
  local text_popup = Popup({
    position = calculate_popup_position(0),
    size = { width = 50, height = 10 },
    border = { style = "rounded" },
  })

  text_popup:mount()
  local text_buf = text_popup.bufnr
  if type(text_lines) == "table" then
    vim.api.nvim_buf_set_lines(text_buf, 0, -1, false, text_lines)
  end
  vim.api.nvim_set_option_value('modifiable', false, {buf = text_buf})
  vim.api.nvim_set_option_value('readonly', true, {buf = text_buf})

  -- ハイライトを適用
  if type(text_lines) == "table" then
    for i, _ in ipairs(text_lines) do
      local highlight_group = (i == current_line) and "Normal" or "Comment"
      vim.api.nvim_buf_add_highlight(text_buf, -1, highlight_group, i - 1, 0, -1)
    end
  end

  return text_popup
end

--- `show_counter` 関数は、カウンターを表示するポップアップを作成し、表示します。
---@param count number 表示するカウンターの値。
function UiPopup:show_counter(count)
  -- 新しいバッファを作成
  if self.count_popup ~= nil then
    self.count_popup:unmount()
  end
  self.count_popup = Popup({
    position = calculate_popup_position(20),
    size = { width = 20, height = 1 },
    border = { style = "rounded" },
  })
  self.count_popup:mount()
  self.count_buf = self.count_popup.bufnr

  self.lines = { tostring(count) }
  vim.api.nvim_buf_set_lines(self.count_buf, 0, -1, false, self.lines)
end

--- `update_counter_display` 関数は、カウンターの表示を更新します。
---@param new_count number 新しいカウンターの値。
function UiPopup:update_counter_display(new_count)
  if self.count_buf then
    vim.schedule(function()
      self.lines = { tostring(new_count) }
      vim.api.nvim_buf_set_lines(self.count_buf, 0, -1, false, self.lines)
    end)
  end
end

--- `unmount_counter` 関数は、counterをunmountする関数を実装したもの
function UiPopup:unmount_counter()
  self.count_popup:unmount()
end

--- `show_result_popup` 関数は、リザルト画面を表示します。
--- @param score number スコア情報
--- @param grade string スコアに基づいたグレード
---@return table result_popup リザルト画面の情報を持ったっテーブル
function UiPopup:show_result_popup(score, grade)
  -- リザルト画面用のポップアップを生成
  local result_popup = Popup({
    position = "50%",
    size = { width = 20, height = 10 },
    border = { style = "rounded" },
  })

  -- ポップアップをマウント
  result_popup:mount()

  -- スコアと成績を表示するためのテキストをバッファに設定
  local bufnr = result_popup.bufnr
  local lines = {
    "Your Score: " .. tostring(score),
    "Your Grade: " .. grade
  }
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- カーソルをポップアップウィンドウに移動
  local win_id = result_popup.winid  -- `winid` フィールドを使用
  vim.api.nvim_set_current_win(win_id)
  vim.api.nvim_win_set_cursor(win_id, {1, 0})  -- ポップアップの最初の行にカーソルを移動

  -- qキーを押したときにポップアップを閉じるキーマッピングを設定
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', {
    callback = function() result_popup:unmount() end,
    noremap = true,
    silent = true
  })

  -- リザルト画面の情報を返す
  return {
    bufnr = bufnr,
    win_id = win_id,
    score = lines[1],
    grade = lines[2]
  }
end

return UiPopup
