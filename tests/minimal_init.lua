local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local nui_dir = os.getenv("NUI_DIR") or "/tmp/nui.nvim"

local function clone_repo(repo_url, dest_dir)
  local is_not_a_directory = vim.fn.isdirectory(dest_dir) == 0
  if is_not_a_directory then
    vim.fn.system({"git", "clone", repo_url, dest_dir})
  end
end

clone_repo("https://github.com/nvim-lua/plenary.nvim", plenary_dir)
clone_repo("https://github.com/MunifTanjim/nui.nvim", nui_dir)

vim.opt.rtp:append(".")
vim.opt.rtp:append(plenary_dir)
vim.opt.rtp:append(nui_dir)

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
