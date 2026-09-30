-- Language servers, formatters, linters and debug adapters all come from
-- Nix (modules/neovim/default.nix) and are on nvim's PATH, so turn off
-- mason's runtime installs. LazyVim then enables every configured server
-- straight from PATH. To add a tool: add the Nix package there, switch.
return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
}
