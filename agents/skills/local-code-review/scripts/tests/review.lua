local function test()
  local api = vim.api
  local root = vim.env.NVIM_REVIEW_ROOT
  local path = vim.env.NVIM_REVIEW_PLAN
  local directory = vim.env.NVIM_REVIEW_STATE_DIR
  assert(
    directory:find("nvim-review-checks", 1, true),
    "Use a temporary progress directory for this check"
  )
  local source = table.concat(vim.fn.readfile(path), "\n")
  local plan = vim.json.decode(source)
  local review = dofile(vim.env.NVIM_REVIEW_HELPER)
  vim.wo.number, vim.wo.wrap = true, false
  review.start()

  local function first_line()
    return api.nvim_buf_get_lines(0, 0, 1, false)[1]
  end

  local function progress()
    local files = vim.fn.glob(directory .. "/*.json", false, true)
    assert(#files == 1, "Expected one test progress record")
    return vim.json.decode(table.concat(vim.fn.readfile(files[1]), "\n")),
      files[1]
  end

  assert(first_line():find(("Chunk 1/" .. #plan.chunks), 1, true))
  assert(#api.nvim_list_tabpages() == 1, "Introduction should use one tab")
  assert(
    vim.fn.maparg("<CR>", "n", false, true).callback,
    "Enter must open the diff"
  )

  local before_invalid = progress()
  local bad_path = directory .. "/../invalid.json"
  local invalid = vim.deepcopy(plan)
  invalid.chunks[1].files[1] = "../outside.ts"
  vim.fn.writefile({ vim.json.encode(invalid) }, bad_path)
  assert(not pcall(review.open, bad_path), "Reject escaping file paths")
  invalid = vim.deepcopy(plan)
  invalid.head = string.rep("0", 40)
  vim.fn.writefile({ vim.json.encode(invalid) }, bad_path)
  assert(not pcall(review.open, bad_path), "Reject a different HEAD")
  review.open(path)
  assert(progress().current == before_invalid.current)

  local buffer = vim.fn.bufadd(root .. "/" .. plan.chunks[1].files[1])
  vim.fn.bufload(buffer)
  vim.bo[buffer].modified = true
  local ok, err = pcall(review.move, 1)
  assert(
    not ok and tostring(err):find("Save your review files", 1, true),
    "Navigation must refuse unsaved review buffers"
  )
  vim.bo[buffer].modified = false

  for index, chunk in ipairs(plan.chunks) do
    assert(first_line():find("Chunk " .. index .. ("/" .. #plan.chunks), 1, true))
    if index == 1 then
      vim.fn.maparg("<CR>", "n", false, true).callback()
    else
      review.enter()
    end
    local view = require("diffview.lib").get_current_view()
    assert(view, "Enter should open Diffview")
    assert(
      vim.wait(10000, function()
        return view.initialized and view.files:len() == #chunk.files
      end, 20),
      "Diffview did not load exactly the chunk's files"
    )
    local actual = {}
    for _, file in view.files:iter() do
      actual[#actual + 1] = file.path
    end
    table.sort(actual)
    local expected = vim.deepcopy(chunk.files)
    table.sort(expected)
    assert(vim.deep_equal(actual, expected), vim.inspect(actual))
    local prefix = "Chunk " .. index .. ("/" .. #plan.chunks)
    assert(
      vim.wait(2000, function()
        for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
          if not vim.wo[win].winbar:find(prefix, 1, true) then
            return false
          end
        end
        return true
      end, 20),
      "Every diff pane should show its chunk counter"
    )
    assert(
      vim.wait(2000, function()
        for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
          local buffer = api.nvim_win_get_buf(win)
          if
            api.nvim_buf_get_name(buffer) == root .. "/" .. chunk.focus.path
          then
            assert(
              vim.wo[win].number and not vim.wo[win].wrap,
              "The diff must restore editor settings after the introduction"
            )
            local line = api.nvim_win_get_cursor(win)[1]
            local text =
              api.nvim_buf_get_lines(buffer, line - 1, line, false)[1]
            return text:find(chunk.focus.text, 1, true) ~= nil
          end
        end
        return false
      end, 20),
      "The selected source buffer must load at the focus anchor"
    )
    for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
      assert(vim.wo[win].winbar:find(prefix, 1, true))
      local rendered = api.nvim_eval_statusline(vim.wo[win].winbar, {
        winid = win,
        use_winbar = true,
        maxwidth = 32,
      })
      assert(
        rendered.str:find(prefix, 1, true),
        "Narrow panes must preserve the counter"
      )
    end
    review.done(false)
    assert(
      #api.nvim_list_tabpages() == 1,
      "Done should close the diff and return to the introduction"
    )
    assert(progress().done[chunk.id], "Done must save the file fingerprint")
  end

  assert(first_line() == "# Review complete")
  assert(progress().complete)
  review.open(path)
  assert(first_line() == "# Review complete", "Resume completion")
  review.done(true)
  assert(not progress().done[plan.chunks[#plan.chunks].id])
  assert(not progress().complete)

  local saved, progress_path = progress()
  saved.done[plan.chunks[1].id] = "outdated-file-fingerprint"
  vim.fn.writefile({ vim.json.encode(saved) }, progress_path)
  review.open(path)
  assert(
    not progress().done[plan.chunks[1].id],
    "A changed file must invalidate completion"
  )
  review.done(false)
  assert(
    first_line():find(("Chunk 1/" .. #plan.chunks), 1, true),
    "Finishing the last chunk should return to unfinished work"
  )

  local moved = directory .. "/../moved-plan.json"
  vim.fn.writefile(vim.fn.readfile(path), moved)
  review.open(moved)
  assert(
    progress().done[plan.chunks[2].id],
    "Moving the plan must preserve progress"
  )
  review.close()
  review.open(path)
  assert(first_line():find(("Chunk 1/" .. #plan.chunks), 1, true))
  review.close()
  print(
    "PASS: intro, Enter, exact file scope, counter, Done, resume, "
      .. "undo, invalidation, saved-file guard, portable path, validation"
  )
end

local ok, err = xpcall(test, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa")
end
