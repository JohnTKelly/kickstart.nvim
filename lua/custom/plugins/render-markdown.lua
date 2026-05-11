return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    -- Used as the icon provider for code block language icons.
    --  `nvim-web-devicons` is already pulled in by telescope.nvim above, so we
    --  reuse it here instead of also installing `mini.icons`.
    'nvim-tree/nvim-web-devicons',
  },
  ft = { 'markdown' },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {},
}
