return {
  'obsidian-nvim/obsidian.nvim',
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

    -- WORKAROUND: extract_note doesn't apply note.template (upstream bug).
    -- The `new` action in actions.lua passes `template = Obsidian.opts.note.template` to
    -- Note.create (line ~474), but `extract_note` (line ~446) does not.
    -- This replaces extract_note with an identical implementation that adds the template.
    -- TODO: Remove once fixed upstream. See: https://github.com/obsidian-nvim/obsidian.nvim/issues/XXX
    -- Original source: lua/obsidian/actions.lua, M.extract_note (~line 424)
    local actions = require 'obsidian.actions'
    local obs_api = require 'obsidian.api'

    -- WORKAROUND: toggle_checkbox skips blank lines even when create_new is enabled.
    -- Both actions.toggle_checkbox and the toggle_checkbox command guard with
    -- `current_line:match "%S"`, which filters out blank/whitespace-only lines before
    -- _toggle_checkbox (which already handles them via create_new) is ever called.
    -- TODO: Remove once fixed upstream.
    local original_toggle = actions._toggle_checkbox
    actions.toggle_checkbox = function(start_lnum, end_lnum)
      local viz = obs_api.get_visual_selection { strict = true }
      local states = Obsidian.opts.checkbox.order
      if viz then
        start_lnum, end_lnum = viz.csrow, viz.cerow
      else
        local row = unpack(vim.api.nvim_win_get_cursor(0))
        start_lnum, end_lnum = row, row
      end
      for line_nb = start_lnum, end_lnum do
        local current_line = vim.api.nvim_buf_get_lines(0, line_nb - 1, line_nb, false)[1]
        if current_line and (current_line:match '%S' or Obsidian.opts.checkbox.create_new) then
          original_toggle(states, line_nb)
        end
      end
    end

    actions.extract_note = function(label)
      local obs_api = require 'obsidian.api'
      local obs_log = require 'obsidian.log'
      local Note = require 'obsidian.note'

      local viz = obs_api.get_visual_selection()
      if not viz then
        obs_log.err '`Obsidian extract_note` must be called in visual mode'
        return
      end

      local content = vim.split(viz.selection, '\n', { plain = true })

      if label ~= nil and string.len(label) > 0 then
        label = vim.trim(label)
      else
        label = obs_api.input 'Enter title (optional): '
        if not label then
          obs_log.warn 'Aborted'
          return
        elseif label == '' then
          label = nil
        end
      end

      -- FIX: pass template and should_write (missing from upstream extract_note)
      local note = Note.create {
        id = label,
        template = Obsidian.opts.note.template,
        should_write = true,
      }

      -- Replace selection with link to new note.
      -- Uses nvim_buf_set_text instead of the upstream's local replace_selection()
      -- which relies on vim.lsp.util.apply_workspace_edit (inaccessible from here).
      local link = note:format_link()
      local bufnr = vim.api.nvim_get_current_buf()
      -- Convert viz.cecol (1-indexed inclusive) to 0-indexed exclusive end column,
      -- accounting for multi-byte UTF-8 characters.
      local end_line = vim.api.nvim_buf_get_lines(bufnr, viz.cerow - 1, viz.cerow, false)[1]
      local end_col = viz.cecol
      if end_line and end_col <= #end_line then
        local byte = end_line:byte(end_col)
        if byte then
          local char_bytes = 1
          if byte >= 240 then
            char_bytes = 4
          elseif byte >= 224 then
            char_bytes = 3
          elseif byte >= 192 then
            char_bytes = 2
          end
          end_col = end_col - 1 + char_bytes
        end
      else
        end_col = #(end_line or '')
      end
      vim.api.nvim_buf_set_text(bufnr, viz.csrow - 1, viz.cscol - 1, viz.cerow - 1, end_col, { link })

      -- Save file so backlinks search (ripgrep) can find the new link
      vim.cmd 'silent! write'

      -- Open new note and append extracted content after the template
      note:open { sync = true }
      vim.api.nvim_buf_set_lines(0, -1, -1, false, content)
    end

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
