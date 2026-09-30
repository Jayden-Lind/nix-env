-- Claude Code IDE integration (the ai.claudecode extra in config/lazy.lua).
-- It runs `claude` in a split and speaks Claude Code's IDE protocol, so
-- Claude sees the current selection/diagnostics and proposes edits as
-- diffs here. A `claude` started in another terminal can attach with /ide.
return {
  {
    "coder/claudecode.nvim",
    keys = {
      -- The extra only maps tree-add for neo-tree/nvim-tree/oil; LazyVim's
      -- default explorer is snacks
      { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add file", ft = "snacks_picker_list" },
    },
  },
}
