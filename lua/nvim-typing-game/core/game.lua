-- core/game.lua
local M = {}

local game_lines = nil
local current_line = 1
local is_over = false
local before_buffer
local error_count = 0

local active_before_buffer = function()
  -- ゲーム終了後に元のバッファに戻す
  local current_window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(current_window, before_buffer)
end

function M.init_game(lines)
  before_buffer = vim.api.nvim_get_current_buf()
  game_lines = lines
  current_line = 1
  is_over = false
end

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
      active_before_buffer()
    end
  else
    error_count = error_count + 1
  end
  return is_correct
end

-- core/game.lua
function M.is_game_over()
  return is_over
  -- ゲームの終了条件は、現在の行がゲーム行数よりも1大きいとき
  -- return current_line > #game_lines
end

function M.get_current_highlighted_line(line_number)
  if game_lines ~= nil then
    return game_lines[line_number]
  end
end

function M.get_registered_words()
  return game_lines
end

function M.get_game_lines_length()
  return #game_lines
end
function M.get_current_line()
  return current_line
end
function M.get_error_count()
  return error_count
end
return M
