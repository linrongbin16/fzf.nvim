local consts = require("fzfx.lib.constants")

local M = {}

--- @alias fzfx.Options table<string, any>
--- @type fzfx.Options
local Defaults = {
  -- the 'Files' commands
  --
  --- @type fzfx.GroupConfig
  files = require("fzfx.cfg.files"),

  -- the 'Live Grep' commands
  --
  --- @type fzfx.GroupConfig
  live_grep = require("fzfx.cfg.live_grep"),

  -- the 'Buffers' commands
  --
  --- @type fzfx.GroupConfig
  buffers = require("fzfx.cfg.buffers"),

  -- the 'Git Files' commands
  --
  --- @type fzfx.GroupConfig
  git_files = require("fzfx.cfg.git_files"),

  -- the 'Git Live Grep' commands
  --
  --- @type fzfx.GroupConfig
  git_live_grep = require("fzfx.cfg.git_live_grep"),

  -- the 'Git Status' commands
  --
  --- @type fzfx.GroupConfig
  git_status = require("fzfx.cfg.git_status"),

  -- the 'Git Branches' commands
  --
  --- @type fzfx.GroupConfig
  git_branches = require("fzfx.cfg.git_branches"),

  -- the 'Git Commits' commands
  --
  --- @type fzfx.GroupConfig
  git_commits = require("fzfx.cfg.git_commits"),

  -- the 'Git Blame' command
  --
  --- @type fzfx.GroupConfig
  git_blame = require("fzfx.cfg.git_blame"),

  -- the 'Vim Commands' commands
  --
  --- @type fzfx.GroupConfig
  vim_commands = require("fzfx.cfg.vim_commands"),

  -- the 'Vim KeyMaps' commands
  --
  --- @type fzfx.GroupConfig
  vim_keymaps = require("fzfx.cfg.vim_keymaps"),

  -- the 'Lsp Diagnostics' command
  --
  --- @type fzfx.GroupConfig
  lsp_diagnostics = require("fzfx.cfg.lsp_diagnostics"),

  -- the 'Lsp Definitions' command
  --
  --- @type fzfx.GroupConfig
  lsp_definitions = require("fzfx.cfg.lsp_definitions"),

  -- the 'Lsp Type Definitions' command
  --
  --- @type fzfx.GroupConfig
  lsp_type_definitions = require("fzfx.cfg.lsp_type_definitions"),

  -- the 'Lsp References' command
  --
  --- @type fzfx.GroupConfig
  lsp_references = require("fzfx.cfg.lsp_references"),

  -- the 'Lsp Implementations' command
  --
  --- @type fzfx.GroupConfig
  lsp_implementations = require("fzfx.cfg.lsp_implementations"),

  -- the 'Lsp Incoming Calls' command
  --
  --- @type fzfx.GroupConfig
  lsp_incoming_calls = require("fzfx.cfg.lsp_incoming_calls"),

  -- the 'Lsp Outgoing Calls' command
  --
  --- @type fzfx.GroupConfig
  lsp_outgoing_calls = require("fzfx.cfg.lsp_outgoing_calls"),

  -- the 'File Explorer' commands
  --
  --- @type fzfx.GroupConfig
  file_explorer = require("fzfx.cfg.file_explorer"),

  -- the 'Yank History' commands
  yank_history = {
    other_opts = {
      maxsize = 100,
    },
  },

  -- the 'Users' commands
  users = nil,

  -- FZF_DEFAULT_OPTS
  fzf_opts = {
    "--ansi",
    "--info=inline",
    "--layout=reverse",
    "--border=rounded",
    "--height=100%",
    consts.FZF_OPTS.TOGGLE,
    consts.FZF_OPTS.TOGGLE_ALL,
    consts.FZF_OPTS.TOGGLE_PREVIEW,
    consts.FZF_OPTS.PREVIEW_HALF_PAGE_UP,
    consts.FZF_OPTS.PREVIEW_HALF_PAGE_DOWN,
  },

  -- global fzf opts with highest priority.
  --
  -- there're two 'fzf_opts' configs: root level, commands level, for example if the configs is:
  --
  -- ```lua
  -- {
  --   live_grep = {
  --     fzf_opts = {
  --       '--disabled',
  --       { '--prompt', 'Live Grep > ' },
  --       { '--preview-window', '+{2}-/2' },
  --     },
  --   },
  --   fzf_opts = {
  --     '--no-multi',
  --     { '--preview-window', 'top,70%' },
  --   },
  -- }
  -- ```
  --
  -- finally the engine will emit below options to the 'fzf' binary:
  -- ```
  -- fzf --no-multi --disabled --prompt 'Live Grep > ' --preview-window '+{2}-/2'
  -- ```
  --
  -- note: the '--preview-window' option in root level will be override by command level (live_grep).
  --
  -- now 'override_fzf_opts' provide the highest priority global options that can override command level 'fzf_opts',
  -- so help users to easier config the fzf opts such as '--preview-window'.
  override_fzf_opts = {},

  -- fzf colors
  -- see: https://github.com/junegunn/fzf/blob/master/README-VIM.md#explanation-of-gfzf_colors
  fzf_color_opts = {
    fg = { "fg", "Normal" },
    bg = { "bg", "Normal" },
    hl = { "fg", "Comment" },
    ["fg+"] = { "fg", "CursorLine", "CursorColumn", "Normal" },
    ["bg+"] = { "bg", "CursorLine", "CursorColumn" },
    ["hl+"] = { "fg", "Statement" },
    info = { "fg", "PreProc" },
    border = { "fg", "Ignore" },
    prompt = { "fg", "Conditional" },
    pointer = { "fg", "Exception" },
    marker = { "fg", "Keyword" },
    spinner = { "fg", "Label" },
    header = { "fg", "Comment" },
    preview_label = { "fg", "Label" },
  },

  -- icons
  -- nerd fonts: https://www.nerdfonts.com/cheat-sheet
  -- unicode: https://symbl.cc/en/
  icons = {
    -- nerd fonts:
    --     nf-fa-file_text_o               \uf0f6
    --     nf-fa-file_o                    \uf016 (default)
    unknown_file = "",

    -- nerd fonts:
    --     nf-custom-folder                \ue5ff (default)
    --     nf-fa-folder                    \uf07b
    -- 󰉋    nf-md-folder                    \udb80\ude4b
    folder = "",

    -- nerd fonts:
    --     nf-custom-folder_open           \ue5fe (default)
    --     nf-fa-folder_open               \uf07c
    -- 󰝰    nf-md-folder_open               \udb81\udf70
    folder_open = "",

    -- nerd fonts:
    --     nf-oct-arrow_right              \uf432
    --     nf-cod-arrow_right              \uea9c
    --     nf-fa-caret_right               \uf0da
    --     nf-weather-direction_right      \ue349
    --     nf-fa-long_arrow_right          \uf178
    --     nf-oct-chevron_right            \uf460
    --     nf-fa-chevron_right             \uf054 (default)
    --
    -- unicode:
    -- https://symbl.cc/en/collections/arrow-symbols/
    -- ➜    U+279C                          &#10140;
    -- ➤    U+27A4                          &#10148;
    fzf_pointer = "",

    -- nerd fonts:
    --     nf-fa-star                      \uf005
    -- 󰓎    nf-md-star                      \udb81\udcce
    --     nf-cod-star_full                \ueb59
    --     nf-oct-dot_fill                 \uf444
    --     nf-fa-dot_circle_o              \uf192
    --     nf-cod-check                    \ueab2
    --     nf-fa-check                     \uf00c
    -- 󰄬    nf-md-check                     \udb80\udd2c
    --
    -- unicode:
    -- https://symbl.cc/en/collections/star-symbols/
    -- https://symbl.cc/en/collections/list-bullets/
    -- https://symbl.cc/en/collections/special-symbols/
    -- •    U+2022                          &#8226;
    -- ✓    U+2713                          &#10003; (default)
    fzf_marker = "✓",
  },

  -- popup window
  popup = {
    -- nvim float window options
    -- see: https://neovim.io/doc/user/api.html#nvim_open_win()
    win_opts = {
      -- popup window height/width.
      --
      -- 1. if 0 <= h/w <= 1, evaluate proportionally according to editor's lines and columns,
      --    e.g. popup height = h * lines, width = w * columns.
      --
      -- 2. if h/w > 1, evaluate as absolute height and width, directly pass to vim.api.nvim_open_win.
      --
      height = 0.85,
      width = 0.85,

      -- popup window position, by default popup window is in the center of editor.
      -- e.g. the option `relative="editor"`.
      -- for now the `relative` options supports:
      --  - editor
      --  - win
      --  - cursor
      --
      -- when relative is 'editor' or 'win', the anchor is the center position, not default 'NW' (north west).
      -- because 'NW' is a little bit complicated for users to calculate the position, usually we just put the popup window in the center of editor.
      --
      -- 1. if -0.5 <= r/c <= 0.5, evaluate proportionally according to editor's lines and columns.
      --    e.g. shift rows = r * lines, shift columns = c * columns.
      --
      -- 2. if r/c <= -1 or r/c >= 1, evaluate as absolute rows/columns to be shift.
      --    e.g. you can easily set 'row = -vim.o.cmdheight' to move popup window to up 1~2 lines (based on your 'cmdheight' option).
      --    this is especially useful when popup window is too big and conflicts with command/status line at bottom.
      --
      -- 3. r/c cannot be in range (-1, -0.5) or (0.5, 1), it makes no sense.
      --
      -- when relative is 'cursor', the anchor is 'NW' (north west).
      -- because we just want to put the popup window relative to the cursor.
      -- so 'row' and 'col' will be directly passed to `vim.api.nvim_open_win` API without any pre-processing.
      --
      row = 0,
      col = 0,
      border = "none",
      zindex = 51,
    },
  },

  -- environment variables
  env = {
    --- @type string|nil
    nvim = nil,
    --- @type string|nil
    fzf = nil,
  },

  cache = {
    dir = require("fzfx.commons.paths").join(
      vim.fn.stdpath("data"),
      "fzfx.nvim"
    ),
  },

  -- debug
  debug = {
    enable = false,
    console_log = true,
    file_log = false,
  },
}

--- @type fzfx.Options
local Configs = {}

--- @param opts fzfx.Options?
--- @return fzfx.Options
M.setup = function(opts)
  Configs = vim.tbl_deep_extend("force", Defaults, opts or {})
  return Configs
end

--- @return fzfx.Options
M.get_config = function()
  return Configs
end

--- @return fzfx.Options
M.get_defaults = function()
  return Defaults
end

return M
