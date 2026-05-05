-- taskwarrior-notes: harpoon-style floating window for Taskwarrior tasks.
-- Notes layout (Neorg .norg):
--   tasks:    ~/.task/notes/<uuid>.norg
--   projects: ~/.task/notes/projects/<project>.norg

local M = {}

local NOTE_DIR = vim.fn.expand("~/.task/notes")
local PROJECT_NOTE_DIR = NOTE_DIR .. "/projects"

local function ensure_dirs()
  vim.fn.mkdir(PROJECT_NOTE_DIR, "p")
end

local function task_export()
  local out = vim.fn.system({ "task", "status:pending", "export" })
  if vim.v.shell_error ~= 0 or out == "" then
    return {}
  end
  local ok, data = pcall(vim.json.decode, out)
  if not ok or type(data) ~= "table" then
    return {}
  end
  return data
end

local function open_task_note(task)
  ensure_dirs()
  local path = NOTE_DIR .. "/" .. task.uuid .. ".norg"
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  vim.fn.system(string.format(
    "task %s mod note:%s 2>/dev/null",
    task.uuid,
    os.date("%Y-%m-%dT%H:%M:%S")
  ))
end

local function open_project_note(project)
  ensure_dirs()
  local path = PROJECT_NOTE_DIR .. "/" .. project .. ".norg"
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

function M.tasks()
  local tasks = task_export()
  if #tasks == 0 then
    vim.notify("No pending tasks", vim.log.levels.INFO)
    return
  end

  table.sort(tasks, function(a, b)
    return (a.urgency or 0) > (b.urgency or 0)
  end)

  local max_id, max_project = 1, 1
  for _, t in ipairs(tasks) do
    max_id = math.max(max_id, #tostring(t.id or ""))
    max_project = math.max(max_project, #(t.project or ""))
  end
  max_project = math.min(max_project, 30)

  local lines = {}
  for _, t in ipairs(tasks) do
    local project = t.project or ""
    if #project > max_project then
      project = project:sub(1, max_project)
    end
    table.insert(lines, string.format(
      "%" .. max_id .. "s  %-" .. max_project .. "s  %s  (%.2f)",
      tostring(t.id or ""),
      project,
      t.description or "",
      t.urgency or 0
    ))
  end

  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = math.min(width + 4, math.floor(vim.o.columns * 0.9))
  local height = math.min(#lines, math.floor(vim.o.lines * 0.6))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "taskwarrior-notes"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Taskwarrior — pending tasks ",
    title_pos = "center",
    footer = " <CR> task note · <C-p> project note · q/<Esc> close ",
    footer_pos = "center",
  })

  vim.wo[win].cursorline = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].wrap = false

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local map = function(key, fn)
    vim.keymap.set("n", key, fn, { buffer = buf, nowait = true, silent = true })
  end

  map("q", close)
  map("<Esc>", close)
  map("<CR>", function()
    local row = vim.api.nvim_win_get_cursor(win)[1]
    local task = tasks[row]
    close()
    if task then open_task_note(task) end
  end)
  map("<C-p>", function()
    local row = vim.api.nvim_win_get_cursor(win)[1]
    local task = tasks[row]
    if not task or not task.project or task.project == "" then
      vim.notify("Task has no project", vim.log.levels.WARN)
      return
    end
    close()
    open_project_note(task.project)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("TaskNotes", function() M.tasks() end, {})
end

return M
