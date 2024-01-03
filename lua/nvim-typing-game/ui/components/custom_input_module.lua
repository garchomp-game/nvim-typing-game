local M = {}

function M.custom_input(on_submit)
  local api = vim.api

  -- ポップアップウィンドウの作成
  local buf = api.nvim_create_buf(false, true)  -- ノンリステッド、スクラッチバッファ
  local win = api.nvim_open_win(buf, false, {
    relative = 'cursor',
    width = 30,
    height = 1,
    col = 0,
    row = 1,
    style = 'minimal',
    border = 'rounded',
  })

  -- プロンプトバッファの設定
  api.nvim_set_option_value('buftype', 'prompt', {buf=buf})
  vim.fn.prompt_setprompt(buf, '> ')

  -- イベントハンドラの設定
  api.nvim_buf_set_keymap(buf, 'i', '<CR>', '', {
    noremap = true,
    callback = function()
      local row, _ = unpack(api.nvim_win_get_cursor(0))
      local text = vim.fn.getline(row)
      on_submit(text)
      -- バッファを削除しない
    end,
  })

  api.nvim_buf_set_keymap(buf, 'i', '<Esc>', '', {
    noremap = true,
    callback = function()
      api.nvim_win_close(win, true)
    end,
  })

  -- ユーザー入力の開始
  vim.cmd('startinsert')
end

return M
