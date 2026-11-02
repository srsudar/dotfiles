local function test()
  vim.v.errmsg = ""
  local directory = vim.env.NVIM_REVIEW_STATE_DIR
  assert(directory:find("nvim-review-checks", 1, true))
  local plan = vim.json.decode(
    table.concat(vim.fn.readfile(vim.env.NVIM_REVIEW_PLAN), "\n")
  )
  local review = dofile(vim.env.NVIM_REVIEW_HELPER)
  local selections = require("diffview.api").selections
  local path = plan.chunks[1].files[1]
  review.start()

  local function enter(index)
    review.enter()
    local view = require("diffview.lib").get_current_view()
    local opened = false
    view.emitter:once("file_open_post", function()
      opened = true
    end)
    assert(vim.wait(10000, function()
      return opened and view.initialized
        and view.files:len() == #plan.chunks[index].files
    end, 20), "Files did not load")
    view.panel:focus()
    return view
  end

  local function press(key)
    local mapping = vim.fn.maparg(key, "n", false, true)
    assert(mapping.callback, "Missing file-panel binding: " .. key)
    mapping.callback()
  end

  local function mark(view)
    for _, file in view.files:iter() do
      if file.path == path then
        view.panel:highlight_file(file)
        press("w")
        break
      end
    end
    assert(selections.is_selected(path, { view = view }))
  end

  local view = enter(1)
  if vim.env.NVIM_REVIEW_TEST_PHASE == "resume" then
    assert(selections.is_selected(path, { view = view }),
      "Marks must survive a new Neovim process")
    assert(view.panel.hide_selected, "Hide state must survive a restart")
    press("C")
    assert(not selections.any(view), "C must clear file marks")
    review.close()
    review.open()
    view = enter(1)
    assert(not selections.any(view), "Cleared marks must stay cleared")
  else
    assert(not selections.any(view))
    mark(view)
    local opened = false
    view.emitter:once("file_open_post", function()
      opened = true
    end)
    press("H")
    assert(vim.wait(10000, function()
      return opened
    end, 20), "H must finish opening the next unmarked file")
    assert(view.panel.hide_selected)
    assert(#view.panel:ordered_file_list() == #plan.chunks[1].files - 1)

    review.move(1)
    view = enter(2)
    assert(not selections.any(view), "Groups must have separate marks")
    review.move(-1)
    view = enter(1)
    assert(selections.is_selected(path, { view = view }),
      "Marks must survive group navigation")
    assert(view.panel.hide_selected)

    local records = vim.fn.glob(directory .. "/*.json", false, true)
    assert(#records == 1)
    local saved = vim.json.decode(
      table.concat(vim.fn.readfile(records[1]), "\n")
    )
    saved.files[plan.chunks[1].id][path] = "previous-file-contents"
    vim.fn.writefile({ vim.json.encode(saved) }, records[1])
    view:update_files()
    assert(vim.wait(10000, function()
      return not selections.is_selected(path, { view = view })
    end, 20), "A stale content fingerprint must clear the mark")
    assert(#view.panel:ordered_file_list() == #plan.chunks[1].files,
      "Changed files must reappear when marked files are hidden")
    mark(view)
  end

  review.close()
  assert(vim.v.errmsg == "", vim.v.errmsg)
  print("PASS: file marks, hide/show, groups, stale contents, restart, clear")
end

local ok, err = xpcall(test, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa")
end
