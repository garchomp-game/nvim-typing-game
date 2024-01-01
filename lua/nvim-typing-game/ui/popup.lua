-- ui/popup.lua
local nui_input = require("nui.input")
local Popup = require("nui.popup")

local M = {}

function M.show_input_popup(on_input_submit)
  local input_popup = nui_input({
    position = "50%",
    size = { width = 20 },
    border = { style = "rounded" },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:Teal" },
  }, {
    prompt = "> ",
    on_submit = on_input_submit
  })

  input_popup:mount()
  return input_popup
end

function M.show_text_popup(text_lines)
  local text_popup = Popup({
    position = "20%",
    size = { width = 50, height = #text_lines },
    border = { style = "rounded" },
  })

  text_popup:mount()
  local text_buf = text_popup.bufnr
  vim.api.nvim_buf_set_lines(text_buf, 0, -1, false, text_lines)
  vim.api.nvim_set_option_value('modifiable', false, {buf = text_buf})
  vim.api.nvim_set_option_value('readonly', true, {buf = text_buf})

  return text_popup
end

return M
