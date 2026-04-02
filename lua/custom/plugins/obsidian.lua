return {
  'obsidian-nvim/obsidian.nvim',
  -- TODO: switch back to version = '*' after next release includes our fixes
  branch = 'main',
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
        overrides = {
          daily_notes = {
            workdays_only = true,
          },
        },
      },
      {
        name = 'personal',
        path = '~/OneDrive/Documents/Obsidian Vault',
        overrides = {
          daily_notes = {
            workdays_only = false,
          },
        },
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
    legacy_commands = false,

    templates = {
      folder = 'Templates',
      substitutions = {
        long_date = function()
          return os.date '%B %d, %Y':gsub(' 0', ' ')
        end,
      },
    },

    note = {
      template = 'Template, Note.md',
    },

    daily_notes = {
      template = 'Template, Daily Note.md',
      date_format = 'YYYYMMDD-[daily-note]',
      alias_format = '[Daily Note]',
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
        ":'<,'>Obsidian extract_note<CR>",
        mode = { 'v' },
        buffer = false,
        desc = 'Extract the visually selected text into a new note and link to it.',
      },
      {
        '<leader>on',
        '<cmd>Obsidian new<CR>',
        buffer = false,
        desc = 'Create a new note.',
      },
      {
        '<leader>oo',
        '<cmd>Obsidian open<CR>',
        buffer = false,
        desc = 'Open a note in the Obsidian app.',
      },
      {
        '<leader>oq',
        '<cmd>Obsidian quick_switch<CR>',
        buffer = false,
        desc = 'Quickly switch to another note in your vault.',
      },
      {
        '<leader>os',
        '<cmd>Obsidian search<CR>',
        buffer = false,
        desc = 'Search for notes in your vault.',
      },
      { '<leader>ot', '<cmd>Obsidian toc<CR>', buffer = false, desc = 'Load the table of contents into a picker list.' },
      { '<leader>od', '<cmd>Obsidian today<CR>', buffer = false, desc = 'Open or create today\'s daily note.' },
      { '<leader>oy', '<cmd>Obsidian yesterday<CR>', buffer = false, desc = 'Open or create yesterday\'s daily note.' },
      { '<leader>oT', '<cmd>Obsidian tomorrow<CR>', buffer = false, desc = 'Open or create tomorrow\'s daily note.' },
      { '<leader>oD', '<cmd>Obsidian dailies<CR>', buffer = false, desc = 'Browse daily notes.' },
      { '<leader>ow', '<cmd>Obsidian workspace<CR>', buffer = false, desc = 'Switch to another workspace.' },
    }
  end,
}
