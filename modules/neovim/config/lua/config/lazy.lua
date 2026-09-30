local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ~/.config/nvim is either a live link into a nix-env checkout (writable)
-- or a read-only copy in the Nix store (see nixEnv.neovim.checkout in
-- modules/neovim/default.nix). lazy.nvim and LazyVim both write files next to
-- init.lua, so in the read-only case keep writable copies in the state dir.
local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
if not vim.uv.fs_access(vim.fn.stdpath("config"), "W") then
  local state = vim.fn.stdpath("state")
  vim.fn.mkdir(state, "p")
  vim.g.lazyvim_json = state .. "/lazyvim.json"

  -- Re-seed from the pinned lockfile whenever the store copy changes, so
  -- `:Lazy restore` always goes back to what the repo pins.
  local pinned = vim.uv.fs_realpath(lockfile) or lockfile
  local stamp = state .. "/lazy-lock.pinned"
  lockfile = state .. "/lazy-lock.json"
  local seeded = vim.fn.filereadable(stamp) == 1 and vim.fn.readfile(stamp)[1] == pinned
  if vim.fn.filereadable(pinned) == 1 and not seeded then
    -- copy the contents, not the store's read-only file mode
    vim.fn.writefile(vim.fn.readfile(pinned, "b"), lockfile, "b")
    vim.fn.writefile({ pinned }, stamp)
  end
end

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- LazyVim extras. Language servers/formatters/linters for each come
    -- from Nix (modules/neovim/default.nix), not mason. `:LazyExtras` can
    -- still toggle more; those land in lazyvim.json.
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.ansible" },
    { import = "lazyvim.plugins.extras.lang.terraform" },
    { import = "lazyvim.plugins.extras.lang.nix" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lang.helm" },
    { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.toml" },
    { import = "lazyvim.plugins.extras.lang.git" },
    { import = "lazyvim.plugins.extras.util.dot" }, -- bashls + shellcheck, dotfile filetypes
    { import = "lazyvim.plugins.extras.formatting.prettier" },
    { import = "lazyvim.plugins.extras.linting.eslint" },
    { import = "lazyvim.plugins.extras.dap.core" }, -- debugger (<leader>d)
    { import = "lazyvim.plugins.extras.test.core" }, -- neotest (<leader>t)
    { import = "lazyvim.plugins.extras.ai.claudecode" }, -- Claude Code (<leader>a)
    { import = "lazyvim.plugins.extras.coding.mini-surround" },
    { import = "lazyvim.plugins.extras.editor.inc-rename" },

    -- import/override with your plugins
    { import = "plugins" },
  },
  lockfile = lockfile,
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- Track each plugin's latest commit; lazy-lock.json (committed) is what
    -- actually pins them.
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  -- No plugin in this config needs luarocks
  rocks = { enabled = false },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
