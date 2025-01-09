return {
  'epwalsh/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = false,
  ft = 'markdown',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    'nvim-lua/plenary.nvim',

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = {
      {
        name = 'work',
        path = '~/OneDrive - Microsoft/Obsidian/JTK Work Vault',
      },
      {
        name = 'personal',
        path = '~/OneDrive/Documents/Obsidian Vault',
      },
    },
    notes_subdir = '0 - INBOX',

    -- Where to put new notes. Valid options are
    --  * "current_dir" - put new notes in same directory as the current buffer.
    --  * "notes_subdir" - put new notes in the default notes subdirectory.
    new_notes_location = 'current_dir',

    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
      local suffix = ''
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.date '%Y%m%d%H%M%S') .. '-' .. suffix
    end,

    picker = {
      -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
      name = 'telescope.nvim',
      -- Optional, configure key mappings for the picker. These are the defaults.
      -- Not all pickers support all mappings.
      note_mappings = {
        -- Create a new note from your query.
        new = '<C-x>',
        -- Insert a link to the selected note.
        insert_link = '<C-l>',
      },
      tag_mappings = {
        -- Add tag(s) to current note.
        tag_note = '<C-x>',
        -- Insert a tag at the current location.
        insert_tag = '<C-l>',
      },
    },
    -- see below for full list of options 👇
  },
  config = function(_, opts)
    require('obsidian').setup(opts)
    local ok, _ = pcall(require, 'which-key')
    if not ok then
      print 'require which-key failed.'
    end
    require('which-key').add {
      { '<leader>o', buffer = false, group = 'Obsidian' },
      {
        '<leader>oe',
        '<cmd>ObsidianExtractNote<CR>',
        buffer = false,
        desc = 'ObsidianExtractNote - Extract the visually selected text into a new note and link to it.',
      },
      {
        '<leader>on',
        '<cmd>ObsidianNew<CR>',
        buffer = false,
        desc = 'ObsidianNew - Create a new note. This command has one optional argument: the title of the new note.',
      },
      {
        '<leader>oo',
        '<cmd>ObsidianOpen<CR>',
        buffer = false,
        desc = 'ObsidianOpen - Open a note in the Obsidian app. This command has one optional argument: a query used to resolve the note to open by ID, path, or alias.',
      },
      {
        '<leader>oq',
        '<cmd>ObsidianQuickSwitch<CR>',
        buffer = false,
        desc = 'ObsidianQuickSwitch - Quickly switch to (or open) another note in your vault, searching by its name using ripgrep with your preferred picker.',
      },
      {
        '<leader>os',
        '<cmd>ObsidianSearch<CR>',
        buffer = false,
        desc = 'ObsidianSearch - Search for (or create) notes in your vault using ripgrep with your preferred picker.',
      },
      { '<leader>ot', '<cmd>ObsidianTOC<CR>', buffer = false, desc = 'ObsidianTOC - Load the table of contents of the current note into a picker list.' },
      { '<leader>ow', '<cmd>ObsidianWorkspace<CR>', buffer = false, desc = 'ObsidianWorkspace - Switch to another workspace.' },
    }
  end,
}
