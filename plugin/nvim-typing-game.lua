--- nvim-typing-game.lua
-- Neovimのタイピングゲームプラグインのメインファイル。
-- このファイルは、ユーザーが実行可能なコマンドを定義し、ゲームの実行を開始する。

local typing_game = require("nvim-typing-game")

--- `TypingGameStart` コマンドは、タイピングゲームを開始します。
vim.api.nvim_create_user_command('TypingGameStart', typing_game.start_game, {})

-- `NvimTypingGenerateHelp` コマンドは、ドキュメントを生成します。
-- ※このコマンドは開発者用です。実際にユーザーが使うことはありません。
vim.api.nvim_create_user_command('NvimTypingGenerateHelp', function()
  -- mini.docのセットアップ
  local status, mini_doc = pcall(require, 'mini.doc')
  if not status then
    print("mini.doc is not installed.")
    return
  end
  mini_doc.setup({})

  -- Luaファイルのパスと出力ファイルのパスを指定
  local home = vim.env.HOME
  local input_files = {
    home .. '/.config/nvim/pack/nvim-typing-game/plugin/nvim-typing-game.lua',
    home .. '/.config/nvim/pack/nvim-typing-game/lua/nvim-typing-game/init.lua',
    home .. '/.config/nvim/pack/nvim-typing-game/lua/nvim-typing-game/core/game.lua',
    home .. '/.config/nvim/pack/nvim-typing-game/lua/nvim-typing-game/ui/popup.lua',
  }
  local output_file = home .. '/.config/nvim/pack/nvim-typing-game/doc/nvim-typing-game-help.txt'

  -- ドキュメント生成
  mini_doc.generate(input_files, output_file)
end, {})
