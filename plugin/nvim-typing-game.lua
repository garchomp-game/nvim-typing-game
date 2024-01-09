local typing_game = require("nvim-typing-game")
vim.api.nvim_create_user_command('TypingGameStart', typing_game.start_game, {})
-- mini.docのセットアップ（必要に応じて設定をカスタマイズ）
require('mini.doc').setup({})

-- Luaファイルのパスを指定
local input_files = {
  '/home/garchomp-game/.config/nvim/pack/nvim-typing-game/lua/nvim-typing-game/init.lua',
  '/home/garchomp-game/.config/nvim/pack/nvim-typing-game/lua/nvim-typing-game/core/game.lua',
  '/home/garchomp-game/.config/nvim/pack/nvim-typing-game/lua/nvim-typing-game/ui/popup.lua'
}

-- 出力ファイルのパスを指定
local output_file = '/home/garchomp-game/.config/nvim/pack/nvim-typing-game/doc/nvim-typing-game-help.txt'

-- ドキュメント生成
require('mini.doc').generate(input_files, output_file)
