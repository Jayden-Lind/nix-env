-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Only run prettier in projects that ship a prettier config, so saving a
-- README or a k8s manifest in an infra repo doesn't reformat it wholesale.
-- Without one, formatting falls back to the language server (if any).
vim.g.lazyvim_prettier_needs_config = true

-- Neovim detects Compose files as plain yaml, so the docker extra's
-- docker_compose_language_service never attached (yamlls still does).
vim.filetype.add({
  pattern = {
    ["docker%-compose[%w.-]*%.ya?ml"] = "yaml.docker-compose",
    ["compose%.ya?ml"] = "yaml.docker-compose",
    ["compose%.[%w.-]+%.ya?ml"] = "yaml.docker-compose",
  },
})
