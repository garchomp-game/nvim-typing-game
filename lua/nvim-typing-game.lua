local module = require("nvim-typing-game.module")
local nui_input = require("nui.input")
local event = require("nui.utils.autocmd").event

local M = {}

local game_buffer = nil
local popup = nil

M.start_game = function()
  game_buffer = vim.api.nvim_get_current_buf()

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local start_line = cursor_pos[1] - 1
  local lines = vim.api.nvim_buf_get_lines(0, start_line, -1, false)

  module.init_game(lines)

  -- NUIポップアップの設定
  local input = nui_input({
    position = "50%",
    size = {
      width = 20
    },
    border = {
      style = "rounded",
      text = {
        top = " Typing Game ",
        top_align = "center"
      }
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Teal",
    },
  }, {
      prompt = "> ",
      on_submit = function(value)
        M.process_input(value)
      end,
    })

  -- ポップアップの表示
  input:mount()

  -- ゲーム終了時にポップアップを閉じる
  input:on(event.BufLeave, function()
    input:unmount()
  end)

  popup = input
end

M.is_game_over = function()
  return module.is_game_over()
end

M.process_input = function(line)
  module.process_input(line)
  if module.is_game_over() then
    if popup then
      popup:unmount()
    end

    if game_buffer and type(game_buffer) == 'number' then
      vim.api.nvim_set_current_buf(game_buffer)
    else
    end
  end
end

M.get_registered_words = function()
  return module.get_registered_words()
end

return M
