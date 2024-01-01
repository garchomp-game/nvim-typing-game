-- core/game.lua
local M = {}

local game_lines = nil
local current_line = 1
local is_over = false

function M.init_game(lines)
  game_lines = lines
  current_line = 1
  is_over = false
end

function M.process_input(line)
  if game_lines ~= nil and game_lines[current_line] == line then
    current_line = current_line + 1
    if current_line > #game_lines then
      is_over = true
    end
  end
end

function M.is_game_over()
  return is_over
end

function M.get_registered_words()
  return game_lines
end

return M
