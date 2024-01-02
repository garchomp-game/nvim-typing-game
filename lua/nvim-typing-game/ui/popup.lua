-- ui/popup.lua
local nui_input = require("nui.input")
local Popup = require("nui.popup")

local M = {}

function M.show_input_popup(on_input_submit)
  local input_popup = nui_input({
    position = "20%",
    size = { width = 50 },
    border = { style = "rounded" },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:Teal" },
  }, {
    prompt = "> ",
    on_submit = on_input_submit
  })

  input_popup:mount()
  return input_popup
end

-- ui/popup.lua の更新部分
function M.show_text_popup(current_line, text_lines)
  local screen_height = vim.api.nvim_win_get_height(0)
  local popup_height = math.floor(screen_height * 0.5)
  local text_popup = Popup({
    position = "20%",
    size = { width = 50, height = popup_height },
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
