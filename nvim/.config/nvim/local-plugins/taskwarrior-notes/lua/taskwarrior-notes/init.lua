-- taskwarrior-notes: Telescope picker for Taskwarrior tasks/projects with note editing.
-- Notes layout matches ~/.task/hooks/note and ~/.task/hooks/project-note:
--   tasks:    ~/.task/notes/<uuid>.md
--   projects: ~/.task/notes/projects/<project>.md

local M = {}

local NOTE_DIR = vim.fn.expand("~/.task/notes")
local PROJECT_NOTE_DIR = NOTE_DIR .. "/projects"

local function ensure_dirs()
  vim.fn.mkdir(PROJECT_NOTE_DIR, "p")
end

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function get_context_filter()
  local ctx = trim(vim.fn.system({ "task", "_get", "rc.context" }))
  if ctx == "" then return {} end
  local filter = trim(vim.fn.system({ "task", "_get", "rc.context." .. ctx .. ".read" }))
  if filter == "" then
    filter = trim(vim.fn.system({ "task", "_get", "rc.context." .. ctx }))
  end
  local tokens = {}
  for tok in filter:gmatch("%S+") do
    table.insert(tokens, tok)
  end
  return tokens
end

local function task_export()
  local args = { "task" }
  for _, t in ipairs(get_context_filter()) do
    table.insert(args, t)
  end
  table.insert(args, "status:pending")
  table.insert(args, "export")
  local out = vim.fn.system(args)
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
  local path = NOTE_DIR .. "/" .. task.uuid .. ".md"
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  -- Record note timestamp on the task (matches ~/.task/hooks/note behavior).
  vim.fn.system(string.format(
    "task %s mod note:%s 2>/dev/null",
    task.uuid,
    os.date("%Y-%m-%dT%H:%M:%S")
  ))
end

local function open_project_note(project)
  ensure_dirs()
  local path = PROJECT_NOTE_DIR .. "/" .. project .. ".md"
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

function M.tasks()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")
  local previewers = require("telescope.previewers")

  local tasks = task_export()
  if #tasks == 0 then
    vim.notify("No pending tasks (in current context)", vim.log.levels.INFO)
    return
  end

  table.sort(tasks, function(a, b)
    return (a.urgency or 0) > (b.urgency or 0)
  end)

  local max_project = 8
  for _, t in ipairs(tasks) do
    if t.project and #t.project > max_project then
      max_project = math.min(#t.project, 30)
    end
  end

  local displayer = entry_display.create({
    separator = "  ",
    items = {
      { width = 4 },
      { width = max_project },
      { remaining = true },
      { width = 6 },
    },
  })

  local make_display = function(entry)
    local t = entry.value
    return displayer({
      { tostring(t.id or ""),               "TelescopeResultsNumber" },
      { t.project or "",                    "TelescopeResultsIdentifier" },
      t.description or "",
      { string.format("%.2f", t.urgency or 0), "TelescopeResultsComment" },
    })
  end

  pickers.new({}, {
    prompt_title = "Taskwarrior — pending tasks  (<CR> task note · <C-p> project note)",
    finder = finders.new_table({
      results = tasks,
      entry_maker = function(t)
        return {
          value = t,
          display = make_display,
          ordinal = string.format("%s %s %s", t.id or "", t.project or "", t.description or ""),
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = "Note preview",
      define_preview = function(self, entry)
        local t = entry.value
        local path = NOTE_DIR .. "/" .. t.uuid .. ".md"
        if vim.fn.filereadable(path) == 1 then
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.fn.readfile(path))
        else
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
            "(no note yet — press <CR> to create)",
            "",
            "Description: " .. (t.description or ""),
            "Project:     " .. (t.project or ""),
            "Urgency:     " .. string.format("%.2f", t.urgency or 0),
            "UUID:        " .. (t.uuid or ""),
          })
        end
        vim.bo[self.state.bufnr].filetype = "markdown"
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then
          open_task_note(entry.value)
        end
      end)
      map({ "i", "n" }, "<C-p>", function()
        local entry = action_state.get_selected_entry()
        if not entry then return end
        if not entry.value.project or entry.value.project == "" then
          vim.notify("Task has no project", vim.log.levels.WARN)
          return
        end
        actions.close(prompt_bufnr)
        open_project_note(entry.value.project)
      end)
      return true
    end,
  }):find()
end

function M.setup()
  vim.api.nvim_create_user_command("TaskNotes", function() M.tasks() end, {})
end

return M
