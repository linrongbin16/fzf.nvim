local tbl = require("fzfx.commons.tbl")
local str = require("fzfx.commons.str")
local num = require("fzfx.commons.num")
local api = require("fzfx.commons.api")
local fileio = require("fzfx.commons.fileio")

local log = require("fzfx.lib.log")
local fzf_helpers = require("fzfx.detail.fzf_helpers")
local popup_helpers = require("fzfx.detail.popup.popup_helpers")

local M = {}

-- calculate bottom line from top line
--- @param top_line integer top line
--- @param content_lines integer content lines count
--- @param view_height integer window/view height
M._calculate_bottom_by_top = function(top_line, content_lines, view_height)
  return num.bound(top_line + view_height - 1, 1, content_lines)
end

-- calculate top line from bottom line
--- @param bottom_line integer bottom line
--- @param content_lines integer content lines count
--- @param view_height integer window/view height
M._calculate_top_by_bottom = function(bottom_line, content_lines, view_height)
  return num.bound(bottom_line - view_height + 1, 1, content_lines)
end

-- adjust top/bottom line based on content lines count and view height
--- @param top integer top line
--- @param bottom integer bottom line
--- @param content_lines integer content lines count
--- @param view_height integer window/view height
--- @return integer, integer top line and bottom line
M._adjust_top_and_bottom = function(top, bottom, content_lines, view_height)
  if top <= 1 then
    -- log.debug(
    --   "|_adjust_view|-1 top(%s) <= 1, bottom:%s, lines_count:%s, win_height:%s",
    --   vim.inspect(top),
    --   vim.inspect(bottom),
    --   vim.inspect(lines_count),
    --   vim.inspect(win_height)
    -- )
    bottom = M._calculate_bottom_by_top(top, content_lines, view_height)
    -- log.debug(
    --   "|_adjust_view|-2 top(%s) <= 1, bottom:%s, lines_count:%s, win_height:%s",
    --   vim.inspect(top),
    --   vim.inspect(bottom),
    --   vim.inspect(lines_count),
    --   vim.inspect(win_height)
    -- )
  elseif bottom >= content_lines then
    -- log.debug(
    --   "|_adjust_view|-3 bottom(%s) >= lines_count(%s), top:%s, win_height:%s",
    --   vim.inspect(bottom),
    --   vim.inspect(lines_count),
    --   vim.inspect(top),
    --   vim.inspect(win_height)
    -- )
    top = M._calculate_top_by_bottom(bottom, content_lines, view_height)
    -- log.debug(
    --   "|_adjust_view|-4 bottom(%s) >= lines_count(%s), top:%s, win_height:%s",
    --   vim.inspect(bottom),
    --   vim.inspect(lines_count),
    --   vim.inspect(top),
    --   vim.inspect(win_height)
    -- )
  end
  return top, bottom
end

-- make a view that start from the 1st line of the content
--- @alias fzfx.BufferPopupWindowPreviewFileContentView {top:integer,bottom:integer,center:integer,highlight:integer?}
--- @param content_lines integer
--- @param win_height integer
--- @return fzfx.BufferPopupWindowPreviewFileContentView
M._make_top_view = function(content_lines, win_height)
  local top = 1
  local bottom = M._calculate_bottom_by_top(top, content_lines, win_height)
  top, bottom = M._adjust_top_and_bottom(top, bottom, content_lines, win_height)
  return { top = top, bottom = bottom, center = math.ceil((top + bottom) / 2), highlight = nil }
end

-- make a view that the focused line is in the middle/center, and it's also the highlighted line.
--- @param content_lines integer
--- @param win_height integer
--- @param center_line integer
--- @return fzfx.BufferPopupWindowPreviewFileContentView
M._make_center_view = function(content_lines, win_height, center_line)
  local top = num.bound(center_line - math.ceil(win_height / 2), 1, content_lines)
  local bottom = M._calculate_bottom_by_top(top, content_lines, win_height)
  top, bottom = M._adjust_top_and_bottom(top, bottom, content_lines, win_height)
  return { top = top, bottom = bottom, center = center_line, highlight = center_line }
end

-- make a view that already know the top/bottom/highlighted line, but needs to be adjusted.
--- @param content_lines integer
--- @param win_height integer
--- @param top_line integer
--- @param bottom_line integer
--- @param highlight_line integer?
M._make_range_view = function(content_lines, win_height, top_line, bottom_line, highlight_line)
  top_line, bottom_line = M._adjust_top_and_bottom(top_line, bottom_line, content_lines, win_height)
  local center_line = math.ceil((top_line + bottom_line) / 2)
  return { top = top_line, bottom = bottom_line, center = center_line, highlight = highlight_line }
end

--- @alias fzfx.BufferFilePreviewerOpts {fzf_preview_window_opts:fzfx.FzfPreviewWindowOpts,fzf_border_opts:string}
--- @param win_opts fzfx.WindowOpts
--- @param buffer_previewer_opts fzfx.BufferFilePreviewerOpts
--- @param relative_winnr integer
--- @return {provider:fzfx.NvimFloatWinOpts,previewer:fzfx.NvimFloatWinOpts}
M._make_cursor_opts = function(win_opts, buffer_previewer_opts, relative_winnr)
  local opts = vim.deepcopy(win_opts)
  local relative = "win"
  local layout =
    popup_helpers.make_cursor_layout(opts, buffer_previewer_opts.fzf_preview_window_opts)
  log.debug("|_make_cursor_opts| layout:" .. vim.inspect(layout))
  local provider_border = fzf_helpers.FZF_BORDER_OPTS_MAP[buffer_previewer_opts.fzf_border_opts]
    or fzf_helpers.FZF_DEFAULT_BORDER_OPTS
  local previewer_border = fzf_helpers.FZF_BORDER_OPTS_MAP[buffer_previewer_opts.fzf_preview_window_opts.border]
    or fzf_helpers.FZF_DEFAULT_BORDER_OPTS

  local result = {
    anchor = "NW",
    relative = relative,
    width = layout.width,
    height = layout.height,
    row = layout.start_row,
    col = layout.start_col,
    style = popup_helpers.FLOAT_WIN_STYLE,
    border = provider_border,
    zindex = popup_helpers.FLOAT_WIN_ZINDEX,
  }
  result.provider = {
    anchor = "NW",
    relative = relative,
    width = layout.provider.width,
    height = layout.provider.height,
    row = layout.provider.start_row,
    col = layout.provider.start_col,
    style = popup_helpers.FLOAT_WIN_STYLE,
    border = provider_border,
    zindex = popup_helpers.FLOAT_WIN_ZINDEX,
  }
  result.previewer = {
    anchor = "NW",
    relative = relative,
    width = layout.previewer.width,
    height = layout.previewer.height,
    row = layout.previewer.start_row,
    col = layout.previewer.start_col,
    style = popup_helpers.FLOAT_WIN_STYLE,
    border = previewer_border,
    zindex = popup_helpers.FLOAT_WIN_ZINDEX,
  }

  if relative == "win" then
    result.provider.win = relative_winnr
    result.previewer.win = relative_winnr
  end
  log.debug("|_make_cursor_opts| result:" .. vim.inspect(result))
  return result
end

--- @param win_opts fzfx.WindowOpts
--- @param buffer_previewer_opts fzfx.BufferFilePreviewerOpts
--- @param relative_winnr integer
--- @return {provider:fzfx.NvimFloatWinOpts,previewer:fzfx.NvimFloatWinOpts}
M._make_center_opts = function(win_opts, buffer_previewer_opts, relative_winnr)
  local opts = vim.deepcopy(win_opts)
  opts.relative = opts.relative or "editor"
  local layout =
    popup_helpers.make_center_layout(opts, buffer_previewer_opts.fzf_preview_window_opts)
  local provider_border = fzf_helpers.FZF_BORDER_OPTS_MAP[buffer_previewer_opts.fzf_border_opts]
    or fzf_helpers.FZF_DEFAULT_BORDER_OPTS
  local previewer_border = fzf_helpers.FZF_BORDER_OPTS_MAP[buffer_previewer_opts.fzf_preview_window_opts.border]
    or fzf_helpers.FZF_DEFAULT_BORDER_OPTS

  local result = {
    anchor = "NW",
    relative = opts.relative,
    width = layout.width,
    height = layout.height,
    row = layout.start_row,
    col = layout.start_col,
    style = popup_helpers.FLOAT_WIN_STYLE,
    border = provider_border,
    zindex = popup_helpers.FLOAT_WIN_ZINDEX,
  }
  result.provider = {
    anchor = "NW",
    relative = opts.relative,
    width = layout.provider.width,
    height = layout.provider.height,
    row = layout.provider.start_row,
    col = layout.provider.start_col,
    style = popup_helpers.FLOAT_WIN_STYLE,
    border = provider_border,
    zindex = popup_helpers.FLOAT_WIN_ZINDEX,
  }
  result.previewer = {
    anchor = "NW",
    relative = opts.relative,
    width = layout.previewer.width,
    height = layout.previewer.height,
    row = layout.previewer.start_row,
    col = layout.previewer.start_col,
    style = popup_helpers.FLOAT_WIN_STYLE,
    border = previewer_border,
    zindex = popup_helpers.FLOAT_WIN_ZINDEX,
  }

  if opts.relative == "win" then
    result.provider.win = relative_winnr
    result.previewer.win = relative_winnr
  end
  -- log.debug("|make_opts| result:%s", vim.inspect(result))
  return result
end

--- @param win_opts fzfx.WindowOpts
--- @param buffer_previewer_opts fzfx.BufferFilePreviewerOpts
--- @param relative_winnr integer
--- @return {provider:fzfx.NvimFloatWinOpts,previewer:fzfx.NvimFloatWinOpts}
M.make_opts = function(win_opts, buffer_previewer_opts, relative_winnr)
  local opts = vim.deepcopy(win_opts)
  opts.relative = opts.relative or "editor"
  log.ensure(
    opts.relative == "cursor" or opts.relative == "editor" or opts.relative == "win",
    string.format("window relative (%s) must be editor/win/cursor", vim.inspect(opts))
  )
  return opts.relative == "cursor"
      and M._make_cursor_opts(opts, buffer_previewer_opts, relative_winnr)
    or M._make_center_opts(opts, buffer_previewer_opts, relative_winnr)
end

-- BufferPopupWindow {

--- @class fzfx.BufferPopupWindow
--- @field window_opts_context fzfx.WindowOptsContext?
--- @field provider_bufnr integer?
--- @field provider_winnr integer?
--- @field previewer_bufnr integer?
--- @field previewer_winnr integer?
--- @field _saved_current_winnr integer
--- @field _saved_win_opts fzfx.WindowOpts
--- @field _saved_buffer_previewer_opts fzfx.BufferFilePreviewerOpts
--- @field _saved_previewing_file_content_job fzfx.BufferPopupWindowPreviewFileContentJob
--- @field _saved_previewing_file_content_view fzfx.BufferPopupWindowPreviewFileContentView
--- @field _current_previewing_file_job_id integer?
--- @field _rendering boolean
--- @field _resizing boolean
--- @field _scrolling boolean
--- @field preview_files_queue fzfx.BufferPopupWindowPreviewFileJob[]
--- @field preview_file_contents_queue fzfx.BufferPopupWindowPreviewFileContentJob[]
--- @field previewer_is_hidden boolean
local BufferPopupWindow = {}

local function _set_default_buf_options(bufnr)
  api.set_buf_option(bufnr, "bufhidden", "wipe")
  api.set_buf_option(bufnr, "buflisted", false)
  api.set_buf_option(bufnr, "filetype", "fzf")
end

--- @param winnr integer
--- @param wrap boolean
local function _set_default_previewer_win_options(winnr, wrap)
  api.set_win_option(winnr, "number", true)
  api.set_win_option(winnr, "spell", false)
  api.set_win_option(winnr, "winhighlight", "Pmenu:,Normal:Normal")
  -- apis.set_win_option(winnr, "scrolloff", 0)
  -- apis.set_win_option(winnr, "sidescrolloff", 0)
  api.set_win_option(winnr, "foldenable", false)
  api.set_win_option(winnr, "wrap", wrap)
end

local function _set_default_provider_win_options(winnr)
  api.set_win_option(winnr, "number", false)
  api.set_win_option(winnr, "spell", false)
  api.set_win_option(winnr, "winhighlight", "Pmenu:,Normal:Normal")
  api.set_win_option(winnr, "colorcolumn", "")
  -- apis.set_win_option(winnr, "scrolloff", 0)
  -- apis.set_win_option(winnr, "sidescrolloff", 0)
  api.set_win_option(winnr, "foldenable", false)
end

--- @package
--- @param win_opts fzfx.WindowOpts
--- @param buffer_previewer_opts fzfx.BufferFilePreviewerOpts
--- @return fzfx.BufferPopupWindow
function BufferPopupWindow:new(win_opts, buffer_previewer_opts)
  local current_winnr = vim.api.nvim_get_current_win()

  -- save current window context
  local window_opts_context = popup_helpers.WindowOptsContext:save()

  --- @type integer
  local provider_bufnr = vim.api.nvim_create_buf(false, true)
  log.ensure(provider_bufnr > 0, "failed to create provider buf")
  _set_default_buf_options(provider_bufnr)

  --- @type integer
  local previewer_bufnr
  if not buffer_previewer_opts.fzf_preview_window_opts.hidden then
    previewer_bufnr = vim.api.nvim_create_buf(false, true)
    log.ensure(previewer_bufnr > 0, "failed to create previewer buf")
    _set_default_buf_options(previewer_bufnr)
  end

  local win_confs = M.make_opts(win_opts, buffer_previewer_opts, current_winnr)
  local provider_win_confs
  local previewer_win_confs

  if not buffer_previewer_opts.fzf_preview_window_opts.hidden then
    provider_win_confs = win_confs.provider
    previewer_win_confs = win_confs.previewer
  else
    provider_win_confs = vim.deepcopy(win_confs)
    provider_win_confs.provider = nil
    provider_win_confs.previewer = nil
  end

  -- log.debug(
  --   "|BufferPopupWindow:new| win_opts:%s, buffer_previewer_opts:%s, win_confs:%s",
  --   vim.inspect(win_opts),
  --   vim.inspect(buffer_previewer_opts),
  --   vim.inspect(win_confs)
  -- )

  local previewer_winnr
  if previewer_bufnr then
    previewer_winnr = vim.api.nvim_open_win(previewer_bufnr, true, previewer_win_confs)
    log.ensure(previewer_winnr > 0, "failed to create previewer win")
    local wrap = buffer_previewer_opts.fzf_preview_window_opts.wrap
    _set_default_previewer_win_options(previewer_winnr, wrap)
  end

  local provider_winnr = vim.api.nvim_open_win(provider_bufnr, true, provider_win_confs)
  log.ensure(provider_winnr > 0, "failed to create provider win")
  _set_default_provider_win_options(provider_winnr)

  -- set cursor at provider window
  vim.api.nvim_set_current_win(provider_winnr)

  vim.api.nvim_create_autocmd("BufEnter", {
    buffer = provider_bufnr,
    nested = true,
    callback = function()
      -- log.debug("|BufferPopupWindow:new| enter provider buffer")
      vim.cmd("startinsert")
    end,
  })

  local o = {
    window_opts_context = window_opts_context,
    provider_bufnr = provider_bufnr,
    provider_winnr = provider_winnr,
    previewer_bufnr = previewer_bufnr,
    previewer_winnr = previewer_winnr,
    _saved_current_winnr = current_winnr,
    _saved_win_opts = win_opts,
    _saved_buffer_previewer_opts = buffer_previewer_opts,
    _saved_previewing_file_content_job = nil,
    _saved_previewing_file_content_view = nil,
    _current_previewing_file_job_id = nil,
    _rendering = false,
    _scrolling = false,
    _resizing = false,
    preview_files_queue = {},
    preview_file_contents_queue = {},
    previewer_is_hidden = buffer_previewer_opts.fzf_preview_window_opts.hidden,
  }
  setmetatable(o, self)
  self.__index = self

  return o
end

function BufferPopupWindow:close()
  -- log.debug(
  --   string.format(
  --     "|BufferPopupWindow:close| provider_winnr:%s, previewer_winnr:%s",
  --     vim.inspect(self.provider_winnr),
  --     vim.inspect(self.previewer_winnr)
  --   )
  -- )

  if type(self.provider_winnr) == "number" and vim.api.nvim_win_is_valid(self.provider_winnr) then
    vim.api.nvim_win_close(self.provider_winnr, true)
    self.provider_winnr = nil
  end
  if type(self.previewer_winnr) == "number" and vim.api.nvim_win_is_valid(self.previewer_winnr) then
    vim.api.nvim_win_close(self.previewer_winnr, true)
    self.previewer_winnr = nil
  end

  self.provider_bufnr = nil
  self.previewer_bufnr = nil
  self.window_opts_context:restore()
end

function BufferPopupWindow:is_resizing()
  return self._resizing
end

function BufferPopupWindow:resize()
  if self._resizing then
    return
  end
  if not self:provider_is_valid() then
    return
  end

  self._resizing = true

  if self.previewer_is_hidden then
    local old_win_confs = vim.api.nvim_win_get_config(self.provider_winnr)
    local new_win_confs = M.make_opts(
      self._saved_win_opts,
      self._saved_buffer_previewer_opts,
      self._saved_current_winnr
    )
    new_win_confs.provider = nil
    new_win_confs.previewer = nil
    -- log.debug(
    --   "|BufferPopupWindow:resize| is hidden, provider - old:%s, new:%s",
    --   vim.inspect(old_provider_win_confs),
    --   vim.inspect(provider_win_confs)
    -- )
    vim.api.nvim_win_set_config(
      self.provider_winnr,
      vim.tbl_deep_extend("force", old_win_confs, new_win_confs)
    )
    _set_default_provider_win_options(self.provider_winnr)
  else
    local old_provider_win_confs = vim.api.nvim_win_get_config(self.provider_winnr)
    local win_confs = M.make_opts(
      self._saved_win_opts,
      self._saved_buffer_previewer_opts,
      self._saved_current_winnr
    )
    -- log.debug(
    --   "|BufferPopupWindow:resize| not hidden, provider - old:%s, new:%s",
    --   vim.inspect(old_provider_win_confs),
    --   vim.inspect(provider_win_confs)
    -- )
    vim.api.nvim_win_set_config(
      self.provider_winnr,
      vim.tbl_deep_extend("force", old_provider_win_confs, win_confs.provider or {})
    )
    _set_default_provider_win_options(self.provider_winnr)

    if self:previewer_is_valid() then
      local old_previewer_win_confs = vim.api.nvim_win_get_config(self.previewer_winnr)
      -- log.debug(
      --   "|BufferPopupWindow:resize| not hidden, previewer - old:%s, new:%s",
      --   vim.inspect(old_previewer_win_confs),
      --   vim.inspect(previewer_win_confs)
      -- )
      vim.api.nvim_win_set_config(
        self.previewer_winnr,
        vim.tbl_deep_extend("force", old_previewer_win_confs, win_confs.previewer or {})
      )

      local wrap = self._saved_buffer_previewer_opts.fzf_preview_window_opts.wrap
      _set_default_previewer_win_options(self.previewer_winnr, wrap)
    end
  end

  vim.schedule(function()
    self._resizing = false
  end)
end

--- @return integer
function BufferPopupWindow:handle()
  return self.provider_winnr
end

function BufferPopupWindow:previewer_is_valid()
  if vim.in_fast_event() then
    return type(self.previewer_winnr) == "number" and type(self.previewer_bufnr) == "number"
  else
    return type(self.previewer_winnr) == "number"
      and vim.api.nvim_win_is_valid(self.previewer_winnr)
      and type(self.previewer_bufnr) == "number"
      and vim.api.nvim_buf_is_valid(self.previewer_bufnr)
  end
end

function BufferPopupWindow:provider_is_valid()
  if vim.in_fast_event() then
    return type(self.provider_winnr) == "number" and type(self.provider_bufnr) == "number"
  else
    return type(self.provider_winnr) == "number"
      and vim.api.nvim_win_is_valid(self.provider_winnr)
      and type(self.provider_bufnr) == "number"
      and vim.api.nvim_buf_is_valid(self.provider_bufnr)
  end
end

--- @param jobid integer
--- @return boolean
function BufferPopupWindow:is_last_previewing_file_job_id(jobid)
  return self._current_previewing_file_job_id == jobid
end

--- @param jobid integer
function BufferPopupWindow:set_current_previewing_file_job_id(jobid)
  self._current_previewing_file_job_id = jobid
end

-- make a view based on preview file content
--- @param preview_file_content fzfx.BufferPopupWindowPreviewFileContentJob
--- @return fzfx.BufferPopupWindowPreviewFileContentView
function BufferPopupWindow:_make_view(preview_file_content)
  log.ensure(preview_file_content ~= nil, "|_make_view| preview_file_content must not be nil")
  log.ensure(self:previewer_is_valid(), "|_make_view| previewer must be valid")
  local center_line = preview_file_content.previewer_result.lineno
  local lines_count = #preview_file_content.contents
  local win_height = vim.api.nvim_win_get_height(self.previewer_winnr)
  local view = center_line and M._make_center_view(lines_count, win_height, center_line)
    or M._make_top_view(lines_count, win_height)
  -- log.debug(
  --   string.format(
  --     "|BufferPopupWindow:_make_view| center_line:%s, lines_count:%s, win_height:%s, view:%s",
  --     vim.inspect(center_line),
  --     vim.inspect(lines_count),
  --     vim.inspect(win_height),
  --     vim.inspect(view)
  --   )
  -- )
  return view
end

--- @alias fzfx.BufferPopupWindowPreviewFileJob {job_id:integer,previewer_result:fzfx.BufferFilePreviewerResult,previewer_label_result:string?}
--- @param job_id integer
--- @param previewer_result fzfx.BufferFilePreviewerResult
--- @param previewer_label_result string?
function BufferPopupWindow:preview_file(job_id, previewer_result, previewer_label_result)
  if str.empty(tbl.tbl_get(previewer_result, "filename")) then
    -- log.debug(
    --   "|BufferPopupWindow:preview_file| empty previewer_result:%s",
    --   vim.inspect(previewer_result)
    -- )
    return
  end

  -- log.debug(
  --   string.format(
  --     "|BufferPopupWindow:preview_file| previewer_result:%s, previewer_label_result:%s",
  --     vim.inspect(previewer_result),
  --     vim.inspect(previewer_label_result)
  --   )
  -- )
  table.insert(self.preview_files_queue, {
    job_id = job_id,
    previewer_result = previewer_result,
    previewer_label_result = previewer_label_result,
  })

  vim.defer_fn(function()
    if #self.preview_files_queue == 0 then
      -- log.debug(
      --   "|BufferPopupWindow:preview_file| empty preview files queue:%s",
      --   vim.inspect(self.preview_files_queue)
      -- )
      return
    end

    local last_job = self.preview_files_queue[#self.preview_files_queue]
    self.preview_files_queue = {}

    -- check if the last job
    if not self:is_last_previewing_file_job_id(last_job.job_id) then
      return
    end

    -- read file content
    fileio.asyncreadfile(last_job.previewer_result.filename, function(contents)
      if not self:is_last_previewing_file_job_id(last_job.job_id) then
        return
      end

      local lines = {}
      if str.not_empty(contents) then
        contents = contents:gsub("\r\n", "\n")
        lines = str.split(contents, "\n")
      end
      table.insert(self.preview_file_contents_queue, {
        contents = lines,
        job_id = last_job.job_id,
        previewer_result = last_job.previewer_result,
        previewer_label_result = last_job.previewer_label_result,
      })

      -- show file contents by lines
      vim.defer_fn(function()
        local last_content = self.preview_file_contents_queue[#self.preview_file_contents_queue]
        self.preview_file_contents_queue = {}
        self._saved_previewing_file_content_job = last_content

        if not self:is_last_previewing_file_job_id(last_content.job_id) then
          return
        end
        if not self:previewer_is_valid() then
          return
        end
        local view = self:_make_view(last_content)
        self:preview_file_contents(last_content, view)
      end, 10)
    end)
  end, 20)
end

--- @alias fzfx.BufferPopupWindowPreviewFileContentJob {contents:string[],job_id:integer,previewer_result:fzfx.BufferFilePreviewerResult,previewer_label_result:string?}
--- @param file_content fzfx.BufferPopupWindowPreviewFileContentJob
--- @param content_view fzfx.BufferPopupWindowPreviewFileContentView
--- @param on_complete (fun(done:boolean):any)|nil
function BufferPopupWindow:preview_file_contents(file_content, content_view, on_complete)
  local function do_complete(done)
    if type(on_complete) == "function" then
      on_complete(done)
    end
  end

  if tbl.tbl_empty(file_content) then
    do_complete(false)
    return
  end

  local file_type = vim.filetype.match({ filename = file_content.previewer_result.filename }) or ""
  api.set_buf_option(self.previewer_bufnr, "filetype", file_type)

  vim.defer_fn(function()
    if not self:previewer_is_valid() then
      do_complete(false)
      return
    end
    if not self:is_last_previewing_file_job_id(file_content.job_id) then
      do_complete(false)
      return
    end

    -- vim.api.nvim_buf_call(self.previewer_bufnr, function()
    --   vim.api.nvim_command([[filetype detect]])
    -- end)

    vim.api.nvim_buf_set_lines(self.previewer_bufnr, 0, -1, false, {})

    local function set_win_title()
      if not self:previewer_is_valid() then
        return
      end
      if not self:is_last_previewing_file_job_id(file_content.job_id) then
        return
      end

      local title_opts = {
        title = file_content.previewer_label_result,
        title_pos = "center",
      }
      vim.api.nvim_win_set_config(self.previewer_winnr, title_opts)
      api.set_win_option(self.previewer_winnr, "number", true)
    end

    if str.not_empty(file_content.previewer_label_result) then
      vim.defer_fn(set_win_title, 100)
    end

    self:render_file_contents(file_content, content_view, on_complete)
  end, 10)
end

--- @param file_content fzfx.BufferPopupWindowPreviewFileContentJob
--- @param content_view fzfx.BufferPopupWindowPreviewFileContentView
--- @param on_complete (fun(done:boolean):any)|nil
--- @param line_step integer?
function BufferPopupWindow:render_file_contents(file_content, content_view, on_complete, line_step)
  local function do_complete(done)
    if type(on_complete) == "function" then
      on_complete(done)
    end
  end

  if tbl.tbl_empty(file_content) then
    do_complete(false)
    return
  end
  if self._rendering then
    do_complete(false)
    return
  end

  local function falsy_rendering()
    vim.schedule(function()
      self._rendering = false
    end)
  end

  self._rendering = true

  vim.defer_fn(function()
    if not self:previewer_is_valid() then
      do_complete(false)
      falsy_rendering()
      return
    end
    if not self:is_last_previewing_file_job_id(file_content.job_id) then
      do_complete(false)
      falsy_rendering()
      return
    end

    local extmark_ns = vim.api.nvim_create_namespace("fzfx-buffer-previewer")
    local old_extmarks = vim.api.nvim_buf_get_extmarks(
      self.previewer_bufnr,
      extmark_ns,
      { 0, 0 },
      { -1, -1 },
      {}
    )
    if tbl.list_not_empty(old_extmarks) then
      for i, m in ipairs(old_extmarks) do
        pcall(vim.api.nvim_buf_del_extmark, self.previewer_bufnr, extmark_ns, m[1])
      end
    end

    local LINES = file_content.contents
    local LINES_COUNT = #LINES
    local LARGE_FILE = LINES_COUNT > 50
    -- local TOP_LINE = content_view
    -- local BOTTOM_LINE = math.min(WIN_HEIGHT + TOP_LINE, LINES_COUNT)
    local FIRST_LINE = 1
    local LAST_LINE = LINES_COUNT
    local line_index = FIRST_LINE
    if line_step == nil then
      line_step = LARGE_FILE and math.max(math.ceil(math.sqrt(LINES_COUNT)), 5) or 5
    end
    -- log.debug(
    --   string.format(
    --     "|BufferPopupWindow:render_file_contents| LINES_COUNT:%s, FIRST/LAST:%s/%s, content_view:%s",
    --     vim.inspect(LINES_COUNT),
    --     vim.inspect(FIRST_LINE),
    --     vim.inspect(LAST_LINE),
    --     vim.inspect(content_view)
    --   )
    -- )

    local function set_buf_lines()
      vim.defer_fn(function()
        if not self:previewer_is_valid() then
          do_complete(false)
          falsy_rendering()
          return
        end
        if not self:is_last_previewing_file_job_id(file_content.job_id) then
          do_complete(false)
          falsy_rendering()
          return
        end

        --- @type {line:string,lineno:integer,length:integer}?
        local hi_line = nil
        --- @type string[]
        local buf_lines = {}
        for i = line_index, line_index + line_step do
          if i <= LAST_LINE then
            if i < (content_view.top - 10) or i > (content_view.bottom + 10) then
              table.insert(buf_lines, "")
            else
              table.insert(buf_lines, LINES[i])
              if type(content_view.highlight) == "number" and content_view.highlight == i then
                hi_line = {
                  line = LINES[i],
                  lineno = i,
                  length = string.len(LINES[i]),
                }
              end
            end
          else
            break
          end
        end

        local set_start = line_index - 1
        local set_end = math.min(line_index + line_step, LAST_LINE) - 1
        -- log.debug(
        --   "|BufferPopupWindow:render_file_contents - set_buf_lines| line_index:%s, set start:%s, end:%s, TOP_LINE/BOTTOM_LINE:%s/%s",
        --   vim.inspect(line_index),
        --   vim.inspect(set_start),
        --   vim.inspect(set_end),
        --   vim.inspect(TOP_LINE),
        --   vim.inspect(BOTTOM_LINE)
        -- )
        vim.api.nvim_buf_set_lines(self.previewer_bufnr, set_start, set_end, false, buf_lines)
        if hi_line then
          local start_row = hi_line.lineno - 1
          local end_row = hi_line.lineno - 1
          local start_col = 0
          local end_col = hi_line.length > 0 and hi_line.length or nil
          local opts = {
            end_row = end_row,
            end_col = end_col,
            strict = false,
            sign_hl_group = "CursorLineSign",
            number_hl_group = "CursorLineNr",
            line_hl_group = "Visual",
          }

          local extmark_ok, extmark = pcall(
            vim.api.nvim_buf_set_extmark,
            self.previewer_bufnr,
            extmark_ns,
            start_row,
            start_col,
            opts
          )
          -- log.debug(
          --   "|BufferPopupWindow:render_file_contents - set_buf_lines| hi_line:%s, extmark ok:%s, extmark:%s, opts:%s",
          --   vim.inspect(hi_line),
          --   vim.inspect(extmark_ok),
          --   vim.inspect(extmark),
          --   vim.inspect(opts)
          -- )
        end

        line_index = line_index + line_step
        if line_index <= content_view.bottom then
          set_buf_lines()
        else
          self:_do_view(content_view)
          self._saved_previewing_file_content_view = content_view
          do_complete(true)
          falsy_rendering()
        end
      end, LARGE_FILE and math.max(10 - string.len(tostring(LINES_COUNT)) * 2, 1) or 10)
    end
    set_buf_lines()
  end, 10)
end

--- @param content_view fzfx.BufferPopupWindowPreviewFileContentView
function BufferPopupWindow:_do_view(content_view)
  local ok, err = pcall(
    vim.api.nvim_win_set_cursor,
    self.previewer_winnr,
    { math.max(1, content_view.center), 0 }
  )
  log.ensure(
    ok,
    string.format(
      "|BufferPopupWindow:_do_view| failed to set cursor, view:%s, err:%s",
      vim.inspect(content_view),
      vim.inspect(err)
    )
  )
  vim.api.nvim_win_call(self.previewer_winnr, function()
    vim.api.nvim_command(string.format([[call winrestview({'topline':%d})]], content_view.top))
  end)
end

--- @param action_name string
function BufferPopupWindow:preview_action(action_name)
  local actions_map = {
    ["hide-preview"] = function()
      self:hide_preview()
    end,
    ["show-preview"] = function()
      self:show_preview()
    end,
    ["refresh-preview"] = function() end,
    ["preview-down"] = function()
      self:preview_page_down()
    end,
    ["preview-up"] = function()
      self:preview_page_up()
    end,
    ["preview-page-down"] = function()
      self:preview_page_down()
    end,
    ["preview-page-up"] = function()
      self:preview_page_up()
    end,
    ["preview-half-page-down"] = function()
      self:preview_half_page_down()
    end,
    ["preview-half-page-up"] = function()
      self:preview_half_page_up()
    end,
    ["preview-bottom"] = function() end,
    ["toggle-preview"] = function()
      self:toggle_preview()
    end,
    ["toggle-preview-wrap"] = function()
      self:toggle_preview()
    end,
  }

  local action = actions_map[action_name]
  if vim.is_callable(action) then
    action()
  end
end

function BufferPopupWindow:show_preview()
  if not self.previewer_is_hidden then
    -- log.debug("|BufferPopupWindow:show_preview| already show")
    return
  end
  if not self:provider_is_valid() then
    -- log.debug("|BufferPopupWindow:show_preview| invalid")
    return
  end
  if self:is_resizing() then
    return
  end

  self.previewer_is_hidden = false
  local win_confs =
    M.make_opts(self._saved_win_opts, self._saved_buffer_previewer_opts, self._saved_current_winnr)
  win_confs.previewer.focusable = false

  self.previewer_bufnr = vim.api.nvim_create_buf(false, true)
  _set_default_buf_options(self.previewer_bufnr)
  self.previewer_winnr = vim.api.nvim_open_win(self.previewer_bufnr, true, win_confs.previewer)
  local wrap = self._saved_buffer_previewer_opts.fzf_preview_window_opts.wrap
  _set_default_previewer_win_options(self.previewer_winnr, wrap)
  vim.api.nvim_set_current_win(self.provider_winnr)

  self:resize()

  -- restore last file preview contents
  vim.schedule(function()
    if not self:previewer_is_valid() then
      return
    end
    if tbl.tbl_not_empty(self._saved_previewing_file_content_job) then
      local last_content = self._saved_previewing_file_content_job
      local last_view = self._saved_previewing_file_content_view ~= nil
          and self._saved_previewing_file_content_view
        or self:_make_view(last_content)
      self:preview_file_contents(last_content, last_view)
    end
  end)
end

function BufferPopupWindow:hide_preview()
  if self.previewer_is_hidden then
    -- log.debug("|BufferPopupWindow:hide_preview| already hidden")
    return
  end
  if not self:provider_is_valid() then
    -- log.debug("|BufferPopupWindow:show_preview| invalid provider")
    return
  end
  if not self:previewer_is_valid() then
    -- log.debug("|BufferPopupWindow:hide_preview| invalid previewer")
    return
  end
  if self:is_resizing() then
    return
  end

  self.previewer_is_hidden = true
  vim.api.nvim_win_close(self.previewer_winnr, true)
  self:resize()
end

function BufferPopupWindow:toggle_preview()
  -- log.debug(
  --   string.format(
  --     "|BufferPopupWindow:toggle_preview| previewer_is_hidden:%s",
  --     vim.inspect(self.previewer_is_hidden)
  --   )
  -- )
  -- already hide, show it
  if self.previewer_is_hidden then
    self:show_preview()
  else
    -- not hide, hide it
    self:hide_preview()
  end
end

-- scroll page up by percentage (1% - 100%)
--- @param percent integer  1-100
--- @param up boolean
function BufferPopupWindow:scroll_by(percent, up)
  if not self:previewer_is_valid() then
    -- log.debug("|BufferPopupWindow:scroll_by| invalid")
    return
  end
  if self._saved_previewing_file_content_job == nil then
    -- log.debug("|BufferPopupWindow:scroll_by| no jobs")
    return
  end
  local file_content = self._saved_previewing_file_content_job
  if not self:is_last_previewing_file_job_id(file_content.job_id) then
    -- log.debug("|BufferPopupWindow:scroll_by| newer jobs")
    return
  end
  if self._scrolling then
    -- log.debug("|BufferPopupWindow:scroll_by| scrolling")
    return
  end
  if self._rendering then
    -- log.debug("|BufferPopupWindow:scroll_by| rendering")
    return
  end

  self._scrolling = true

  local function falsy_scrolling()
    vim.schedule(function()
      self._scrolling = false
    end)
  end

  local LINES = file_content.contents
  local LINES_COUNT = #LINES
  local WIN_HEIGHT = vim.api.nvim_win_get_height(self.previewer_winnr)

  local TOP_LINE = tbl.tbl_get(self._saved_previewing_file_content_view, "top")
    or vim.fn.line("w0", self.previewer_winnr)
  local BOTTOM_LINE = tbl.tbl_get(self._saved_previewing_file_content_view, "bottom")
    or math.min(TOP_LINE + WIN_HEIGHT, LINES_COUNT)
  local CENTER_LINE = tbl.tbl_get(self._saved_previewing_file_content_view, "center")
    or math.ceil((TOP_LINE + BOTTOM_LINE) / 2)
  local HIGHLIGHT_LINE = tbl.tbl_get(self._saved_previewing_file_content_view, "highlight")

  local shift_lines = math.max(math.floor(WIN_HEIGHT / 100 * percent), 0)
  if up then
    shift_lines = -shift_lines
  end
  local first_line = num.bound(TOP_LINE + shift_lines, 1, LINES_COUNT)
  local last_line = M._calculate_bottom_by_top(first_line, LINES_COUNT, WIN_HEIGHT)
  -- log.debug(
  --   "|BufferPopupWindow:scroll_by|-1 percent:%s, up:%s, LINES/HEIGHT/SHIFT:%s/%s/%s, top/bottom/center:%s/%s/%s, first/last:%s/%s",
  --   vim.inspect(percent),
  --   vim.inspect(up),
  --   vim.inspect(LINES_COUNT),
  --   vim.inspect(WIN_HEIGHT),
  --   vim.inspect(shift_lines),
  --   vim.inspect(TOP_LINE),
  --   vim.inspect(BOTTOM_LINE),
  --   vim.inspect(CENTER_LINE),
  --   vim.inspect(first_line),
  --   vim.inspect(last_line)
  -- )
  local view = M._make_range_view(LINES_COUNT, WIN_HEIGHT, first_line, last_line, HIGHLIGHT_LINE)
  -- log.debug(
  --   string.format(
  --     "|BufferPopupWindow:scroll_by|-2 percent:%s, up:%s, LINES/HEIGHT/SHIFT:%s/%s/%s, top/bottom/center:%s/%s/%s, view:%s",
  --     vim.inspect(percent),
  --     vim.inspect(up),
  --     vim.inspect(LINES_COUNT),
  --     vim.inspect(WIN_HEIGHT),
  --     vim.inspect(shift_lines),
  --     vim.inspect(TOP_LINE),
  --     vim.inspect(BOTTOM_LINE),
  --     vim.inspect(CENTER_LINE),
  --     vim.inspect(view)
  --   )
  -- )

  if TOP_LINE == view.top and BOTTOM_LINE == view.bottom then
    -- log.debug("|BufferPopupWindow:scroll_by| no change")
    falsy_scrolling()
    return
  end

  self:render_file_contents(file_content, view, falsy_scrolling, math.max(LINES_COUNT, 30))
end

function BufferPopupWindow:preview_page_down()
  self:scroll_by(100, false)
end

function BufferPopupWindow:preview_page_up()
  self:scroll_by(100, true)
end

function BufferPopupWindow:preview_half_page_down()
  self:scroll_by(50, false)
end

function BufferPopupWindow:preview_half_page_up()
  self:scroll_by(50, true)
end

M.BufferPopupWindow = BufferPopupWindow

-- BufferPopupWindow }

return M
