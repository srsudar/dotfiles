local M = {}
local api = vim.api
local state = {}
local intro_options = {
  number = false,
  relativenumber = false,
  wrap = true,
  linebreak = true,
  foldmethod = "manual",
  signcolumn = "no",
}

local function window_options(win, options)
  for name, value in pairs(options) do
    vim.wo[win][name] = value
  end
end

local function read(path)
  local file = io.open(path, "rb")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  return content
end

local function git(args)
  local command = { "git", "-c", "core.fsmonitor=false", "-C", state.repo }
  vim.list_extend(command, args)
  local result = vim
    .system(command, {
      text = true,
      env = { GIT_OPTIONAL_LOCKS = "0" },
    })
    :wait(5000)
  assert(result.code == 0, vim.trim(result.stderr or "Git command failed"))
  return vim.trim(result.stdout)
end

local function commit(value)
  return type(value) == "string" and #value == 40 and value:match("^%x+$")
end

local function relative(path)
  assert(type(path) == "string" and path ~= "", "Missing file path")
  assert(
    path:sub(1, 1) ~= "/" and not path:find("[%c]"),
    "File paths must be relative to the checkout"
  )
  for segment in path:gmatch("[^/]+") do
    assert(segment ~= "." and segment ~= "..", "Invalid file path")
  end
end

local function fingerprint(chunk)
  local parts = {}
  for _, path in ipairs(chunk.files) do
    local content = read(state.repo .. "/" .. path)
    parts[#parts + 1] = path
    parts[#parts + 1] = content and vim.fn.sha256(content) or "deleted"
  end
  return vim.fn.sha256(table.concat(parts, "\n"))
end

local function file_fingerprint(path)
  local content = read(state.repo .. "/" .. path)
  return content and vim.fn.sha256(content) or "deleted"
end

local function save()
  vim.fn.mkdir(state.directory, "p")
  local temporary = state.progress_path .. "." .. vim.fn.getpid() .. ".tmp"
  local file = assert(io.open(temporary, "wb"))
  assert(file:write(vim.json.encode(state.progress) .. "\n"))
  assert(file:close())
  assert(os.rename(temporary, state.progress_path))
end

local function load()
  local content = assert(read(state.path), "No review plan at " .. state.path)
  local plan = vim.json.decode(content)
  assert(plan.version == 2, "This launcher requires a version 2 review plan")
  assert(type(plan.id) == "string" and plan.id ~= "", "Plan needs an id")
  assert(type(plan.title) == "string", "Plan needs a title")
  assert(
    commit(plan.base) and commit(plan.head),
    "Base and head must be full commit IDs"
  )
  assert(
    git({ "rev-parse", "HEAD" }) == plan.head,
    "HEAD changed. Refresh the plan or use its original review worktree."
  )
  git({ "cat-file", "-e", plan.base .. "^{commit}" })
  assert(
    vim.islist(plan.chunks) and #plan.chunks > 0,
    "Plan needs at least one chunk"
  )
  local ids = {}
  for _, chunk in ipairs(plan.chunks) do
    assert(
      type(chunk.id) == "string" and chunk.id ~= "" and not ids[chunk.id],
      "Chunk IDs must be unique nonempty strings"
    )
    ids[chunk.id] = true
    assert(
      type(chunk.title) == "string" and type(chunk.summary) == "string",
      "Each chunk needs a title and summary"
    )
    assert(
      vim.islist(chunk.files) and #chunk.files > 0,
      "Each chunk needs files"
    )
    for _, path in ipairs(chunk.files) do
      relative(path)
    end
    if chunk.focus then
      assert(
        vim.tbl_contains(chunk.files, chunk.focus.path)
          and type(chunk.focus.text) == "string"
          and chunk.focus.text ~= "",
        "Focus needs a file in the chunk and nonempty literal text"
      )
    end
  end
  local key = vim.fn.sha256(state.repo .. "\n" .. plan.id):sub(1, 24)
  state.progress_path = state.directory .. "/" .. key .. ".json"
  local saved = read(state.progress_path)
  local progress = saved and vim.json.decode(saved) or {}
  local digest = vim.fn.sha256(content)
  if progress.plan_digest ~= digest then
    progress = { plan_digest = digest, current = plan.chunks[1].id, done = {} }
  end
  assert(type(progress.done) == "table", "Invalid review progress")
  progress.files = progress.files or {}
  progress.hidden = progress.hidden or {}
  progress.plan_path, progress.worktree = state.path, state.repo
  local invalidated = false
  for _, chunk in ipairs(plan.chunks) do
    local marks = progress.files[chunk.id] or {}
    for path, hash in pairs(marks) do
      if hash ~= file_fingerprint(path) then
        marks[path] = nil
        invalidated = true
      end
    end
    if
      progress.done[chunk.id]
      and progress.done[chunk.id] ~= fingerprint(chunk)
    then
      progress.done[chunk.id] = nil
      invalidated = true
    end
  end
  state.plan, state.progress = plan, progress
  if invalidated then
    progress.complete = false
    save()
    vim.notify("Changed files cleared their review marks.")
  end
end

local function current()
  assert(state.path, "Run :ReviewOpen first")
  load()
  for index, chunk in ipairs(state.plan.chunks) do
    if chunk.id == state.progress.current then
      return index
    end
  end
  return 1
end

local function require_saved()
  local paths = {}
  for _, chunk in ipairs(state.plan.chunks) do
    for _, path in ipairs(chunk.files) do
      paths[state.repo .. "/" .. path] = true
    end
  end
  for _, buffer in ipairs(api.nvim_list_bufs()) do
    if paths[api.nvim_buf_get_name(buffer)] and vim.bo[buffer].modified then
      error("Save your review files (:wa) before continuing.", 0)
    end
  end
end

local function label(index)
  return ("Chunk %d/%d"):format(index, #state.plan.chunks)
end

local function guard(callback)
  return function(...)
    local ok, err = pcall(callback, ...)
    if not ok then
      vim.notify(tostring(err), vim.log.levels.ERROR, { title = "Review" })
    end
  end
end

local function remember_marks(view)
  if
    state.restoring_marks
    or not state.marks_ready
    or not view
    or view.tabpage ~= state.tab
  then
    return
  end

  local chunk = state.plan.chunks[state.index]
  local previous = state.progress.files[chunk.id] or {}
  local marks = {}
  for _, path in ipairs(require("diffview.api").selections.get_paths(view)) do
    marks[path] = previous[path] or file_fingerprint(path)
  end
  state.progress.files[chunk.id] = marks
  state.progress.hidden[chunk.id] = view.panel.hide_selected
  save()
end

local function restore_marks(view)
  if view.tabpage ~= state.tab then
    return
  end

  load()
  local chunk = state.plan.chunks[state.index]
  local marks = state.progress.files[chunk.id] or {}
  state.restoring_marks = true
  require("diffview.api").selections.set(vim.tbl_keys(marks), { view = view })
  state.restoring_marks = false
  state.marks_ready = true
  view.panel.hide_selected = state.progress.hidden[chunk.id] or false
  view.panel:update_components()
  view.panel:render()
  view.panel:redraw()
end

local function close_diff()
  if state.tab and api.nvim_tabpage_is_valid(state.tab) then
    api.nvim_set_current_tabpage(state.tab)
    require("diffview").close()
  end
  state.tab = nil
  state.marks_ready = false
end

local function decorate()
  if not state.tab or not api.nvim_tabpage_is_valid(state.tab) then
    return
  end
  local chunk = state.plan.chunks[state.index]
  local heading = label(state.index) .. " %<" .. chunk.title:gsub("%%", "%%%%")
  for _, win in ipairs(api.nvim_tabpage_list_wins(state.tab)) do
    vim.wo[win].winbar = heading
    local buffer = api.nvim_win_get_buf(win)
    if
      state.pending_focus
      and chunk.focus
      and api.nvim_buf_get_name(buffer)
        == state.repo .. "/" .. chunk.focus.path
    then
      for line, text in ipairs(api.nvim_buf_get_lines(buffer, 0, -1, false)) do
        if text:find(chunk.focus.text, 1, true) then
          api.nvim_win_set_cursor(win, { line, 0 })
          api.nvim_win_call(win, function()
            vim.cmd("normal! zvzt")
          end)
          state.pending_focus = false
          break
        end
      end
    end
  end
end

local function checklist(lines)
  vim.list_extend(lines, { "", "Review checklist", "" })
  for index, chunk in ipairs(state.plan.chunks) do
    lines[#lines + 1] = ("%s %d. %s"):format(
      state.progress.done[chunk.id] and "[x]" or "[ ]",
      index,
      chunk.title
    )
  end
end

local function wrap_summary(summary)
  local lines = {}
  for _, paragraph in ipairs(vim.split(summary, "\n", { plain = true })) do
    local line = ""
    for word in paragraph:gmatch("%S+") do
      local candidate = line == "" and word or line .. " " .. word
      if line ~= "" and vim.fn.strdisplaywidth(candidate) > 80 then
        lines[#lines + 1] = line
        line = word
      else
        line = candidate
      end
    end
    lines[#lines + 1] = line
  end
  return lines
end

local function introduction(index, finished)
  assert(
    index >= 1 and index <= #state.plan.chunks,
    index < 1 and "Already at the first chunk" or "Already at the last chunk"
  )
  require_saved()
  close_diff()
  if not state.home or not api.nvim_tabpage_is_valid(state.home) then
    vim.cmd("tabnew")
    state.home = api.nvim_get_current_tabpage()
  end
  api.nvim_set_current_tabpage(state.home)
  local chunk = state.plan.chunks[index]
  state.index = index
  state.progress.current = chunk.id
  state.progress.complete = finished or false
  save()
  if not state.intro or not api.nvim_buf_is_valid(state.intro) then
    state.intro = api.nvim_create_buf(false, true)
    api.nvim_buf_set_name(state.intro, "review://introduction")
    vim.bo[state.intro].bufhidden = "hide"
    vim.bo[state.intro].swapfile = false
    vim.bo[state.intro].filetype = "markdown"
    vim.keymap.set("n", "<CR>", guard(M.enter), { buffer = state.intro })
    vim.keymap.set(
      "n",
      "q",
      guard(function()
        require_saved()
        vim.cmd("qa")
      end),
      { buffer = state.intro }
    )
  end
  local lines
  if finished then
    lines = { "# Review complete", "", state.plan.title }
  else
    lines = {
      "# " .. label(index) .. " — " .. chunk.title,
      "",
      state.plan.title,
      "",
    }
    vim.list_extend(lines, wrap_summary(chunk.summary))
    vim.list_extend(lines, { "", "Files", "" })
    for _, path in ipairs(chunk.files) do
      lines[#lines + 1] = "  " .. path
    end
    vim.list_extend(lines, { "", "Enter: open this chunk in Diffview" })
    vim.list_extend(lines, {
      "In the file panel: w marks a file, H hides marked files, C clears marks.",
    })
  end
  checklist(lines)
  vim.list_extend(lines, {
    "",
    ":ReviewDone: mark this chunk reviewed and continue",
    ":ReviewDone!: unmark this chunk",
    ":ReviewNext / :ReviewPrev: move without marking reviewed",
    ":ReviewInfo: return to this introduction",
    "q: quit Neovim",
    "",
    "Save AGENT comments in the files, then ask the agent to read them.",
    "",
    "Working files: " .. state.repo,
    "Base: " .. state.plan.base,
    "Plan: " .. state.path,
  })
  vim.bo[state.intro].modifiable = true
  api.nvim_buf_set_lines(state.intro, 0, -1, false, lines)
  vim.bo[state.intro].modifiable = false
  api.nvim_set_current_buf(state.intro)
  window_options(0, intro_options)
  vim.wo.winbar = finished and "Review complete" or label(index)
  api.nvim_win_set_cursor(0, { 1, 0 })
end

function M.enter()
  local index = current()
  require_saved()
  close_diff()
  local chunk = state.plan.chunks[index]
  local selected = chunk.focus and chunk.focus.path or chunk.files[1]
  local args = {
    state.plan.base,
    "-C" .. state.repo,
    "--untracked-files=all",
    "--selected-file=" .. selected,
    "--",
  }
  for _, path in ipairs(chunk.files) do
    args[#args + 1] = ":(top,literal)" .. path
  end
  local before = api.nvim_get_current_tabpage()
  local intro_win = api.nvim_get_current_win()
  local intro_winbar = vim.wo[intro_win].winbar
  window_options(intro_win, state.editor_options)
  local ok, err = pcall(require("diffview").open, args)
  window_options(intro_win, intro_options)
  vim.wo[intro_win].winbar = intro_winbar
  assert(ok, err)
  local tab = api.nvim_get_current_tabpage()
  assert(tab ~= before, "Diffview could not open the chunk")
  state.tab, state.index, state.pending_focus = tab, index, false
  local view = require("diffview.lib").get_current_view()
  view.emitter:on("files_updated", function()
    restore_marks(view)
  end)
  vim.keymap.set("n", "H", function()
    require("diffview.actions").toggle_hide_selected()
    remember_marks(view)
  end, { buffer = view.panel.bufid, desc = "Hide/show reviewed files" })
  local allowed = {}
  for _, path in ipairs(chunk.files) do
    allowed[path] = true
  end
  -- Diffview hides untracked files against commits and ignores their path
  -- filters. Scope this adapter so new files join the intended review chunk.
  view.adapter.show_untracked = function()
    return true
  end
  local async = require("diffview.async")
  local untracked = view.adapter.untracked_files
  view.adapter.untracked_files = async.wrap(
    function(adapter, left, right, options, callback)
      local err, files = async.await(untracked(adapter, left, right, options))
      callback(err, files and vim.tbl_filter(function(file)
        return allowed[file.path] == true
      end, files))
    end
  )
  view.emitter:once("file_open_post", function()
    vim.schedule(function()
      if state.tab == tab then
        state.pending_focus = true
        decorate()
      end
    end)
  end)
  decorate()
end

function M.open(path)
  if state.plan then
    require_saved()
    close_diff()
  end
  state.path = vim.fn.fnamemodify(
    path and path ~= "" and path or state.path or vim.env.NVIM_REVIEW_PLAN,
    ":p"
  )
  local index = current()
  introduction(index, state.progress.complete)
end

function M.move(delta)
  introduction(current() + delta, false)
end

function M.done(undo)
  local index = current()
  require_saved()
  local chunk = state.plan.chunks[index]
  if undo then
    state.progress.done[chunk.id] = nil
    introduction(index, false)
    return
  end
  state.progress.done[chunk.id] = fingerprint(chunk)
  if index < #state.plan.chunks then
    introduction(index + 1, false)
    return
  end
  for next_index, next_chunk in ipairs(state.plan.chunks) do
    if not state.progress.done[next_chunk.id] then
      introduction(next_index, false)
      return
    end
  end
  introduction(index, true)
end

function M.info()
  introduction(current(), state.progress.complete)
end

function M.close()
  require_saved()
  close_diff()
  if state.intro and api.nvim_buf_is_valid(state.intro) then
    api.nvim_buf_delete(state.intro, {})
  end
  state.intro = nil
end

function M.start()
  local ok, diff_api = pcall(require, "diffview.api")
  assert(
    ok and diff_api.selections,
    "File marks require Diffview Plus. Start a fresh Neovim."
  )
  state.repo = assert(vim.env.NVIM_REVIEW_ROOT, "Missing review checkout")
  state.directory =
    assert(vim.env.NVIM_REVIEW_STATE_DIR, "Missing progress directory")
  -- The wrapper owns per-chunk marks and invalidates changed file contents.
  -- Native persistence is scoped only by repository and revision.
  require("diffview.config").get_config().persist_selections.enabled = false
  DiffviewGlobal.emitter:on("selection_changed", function(_, view)
    remember_marks(view)
  end)
  state.home = api.nvim_get_current_tabpage()
  state.editor_options = { winbar = vim.wo.winbar }
  for name in pairs(intro_options) do
    state.editor_options[name] = vim.wo[name]
  end
  local function command(name, callback, opts)
    api.nvim_create_user_command(name, guard(callback), opts or {})
  end
  command("ReviewOpen", function(args)
    M.open(args.args)
  end, { nargs = "?", complete = "file" })
  command("ReviewNext", function()
    M.move(1)
  end)
  command("ReviewPrev", function()
    M.move(-1)
  end)
  command("ReviewDone", function(args)
    M.done(args.bang)
  end, { bang = true })
  command("ReviewInfo", M.info)
  command("ReviewClose", M.close)
  local group = api.nvim_create_augroup("agent_review", { clear = true })
  api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "DiffviewDiffBufWinEnter", "DiffviewViewPostLayout" },
    callback = function()
      vim.schedule(decorate)
    end,
  })
  M.open()
end

return M
