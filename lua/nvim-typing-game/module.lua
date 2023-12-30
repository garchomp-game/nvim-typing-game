local M = {}

local game_lines = nil
local current_line = 1
local is_over = false

M.init_game = function(lines)
  game_lines = lines
  current_line = 1
  is_over = false
end

M.process_input = function(line)
  if game_lines ~= nil and game_lines[current_line] == line then
    current_line = current_line + 1
    if current_line > #game_lines then
      is_over = true
    end
  end
end

M.is_game_over = function()
  return is_over
end

return M
