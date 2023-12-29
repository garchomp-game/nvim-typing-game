local TypingGame = require("nvim-typing-game.module")

local M = {}

M.start_game = function()
  -- カーソルの現在位置を取得
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local start_line = cursor_pos[1] - 1  -- 0-indexed

  -- ゲームに使用するバッファの行を取得
  local lines = vim.api.nvim_buf_get_lines(0, start_line, -1, false)

  -- タイピングゲームのロジックを初期化
  TypingGame.init_game(lines)

  -- ゲームUIの表示（nui.nvimを利用）
  -- ここでポップアップウィンドウなどを表示するコードを実装
end

return M
