-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- yamlls reformats on save (quote style, wrapping, indentation), which
-- turns small edits to Ansible/k8s/Helm YAML into noisy diffs. Keep it
-- manual: <leader>cf formats, <leader>uF re-enables it for the buffer.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("yaml_no_autoformat", { clear = true }),
  pattern = { "yaml", "yaml.*" },
  callback = function(ev)
    vim.b[ev.buf].autoformat = false
  end,
})
