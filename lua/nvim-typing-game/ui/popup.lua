-- ui/popup.lua
local nui_input = require("nui.input")
local Popup = require("nui.popup")

local M = {}

local function calculate_popup_position(popup_height)
  local win_height = vim.api.nvim_win_get_height(0)
  local center_row = math.floor(win_height / 2)
  local position_row = center_row - math.floor(popup_height / 2)
  return { row = position_row, col = "50%" }
end

function M.show_input_popup(on_input_submit, on_input_change)
  local input_popup = nui_input({
    position = calculate_popup_position(10),
    size = { width = 50 },
    border = { style = "rounded" },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:Teal" },
  }, {
    prompt = "> ",
    on_submit = on_input_submit,
    on_change = on_input_change
  })

  input_popup:mount()
  return input_popup
end

-- ui/popup.lua の更新部分
function M.show_text_popup(current_line, text_lines)
  local text_popup = Popup({
    position = calculate_popup_position(0),
    size = { width = 50, height = 20 },
    border = { style = "rounded" },
  })

  text_popup:mount()
  local text_buf = text_popup.bufnr

  vim.api.nvim_buf_set_lines(text_buf, 0, -1, false, text_lines)
  vim.api.nvim_set_option_value('modifiable', false, {buf = text_buf})
  vim.api.nvim_set_option_value('readonly', true, {buf = text_buf})

  -- ハイライトを適用
  for i, _ in ipairs(text_lines) do
    local highlight_group = (i == current_line) and "Normal" or "Comment"
    vim.api.nvim_buf_add_highlight(text_buf, -1, highlight_group, i - 1, 0, -1)
  end

  return text_popup
end

return M
