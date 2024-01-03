-- core/game.lua
local M = {}

local game_lines = {}
local current_line = 1
local is_over = false

function M.init_game(lines)
  game_lines = lines
  current_line = 1
  is_over = false
end

function M.process_input(line)
  local is_correct = false
  if game_lines ~= nil and game_lines[current_line] == line then
    is_correct = true
    if current_line > #game_lines then
      is_over = true
    end
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
  return game_lines[line_number]
end

function M.get_registered_words()
  return game_lines
end

return M
