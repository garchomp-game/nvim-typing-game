local nvim_typing_game = require("nvim-typing-game")
vim.api.nvim_create_user_command('TypingGameStart', nvim_typing_game.start_game, {})
