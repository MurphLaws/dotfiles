-- taskwarrior-notes: telescope picker for Taskwarrior tasks.
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

local function task_has_note(task)
  return vim.fn.filereadable(NOTE_DIR .. "/" .. (task.uuid or "") .. ".norg") == 1
end

local function project_has_note(project)
  if not project or project == "" then return false end
  return vim.fn.filereadable(PROJECT_NOTE_DIR .. "/" .. project .. ".norg") == 1
end

local function age(iso)
  if not iso then return "" end
  local y, mo, d, h, mi, s = iso:match("(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)Z")
  if not y then return "" end
  local t = os.time({
    year = tonumber(y), month = tonumber(mo), day = tonumber(d),
    hour = tonumber(h), min = tonumber(mi), sec = tonumber(s),
  })
  local diff = os.time() - t
  if diff < 60        then return diff .. "s"                     end
  if diff < 3600      then return math.floor(diff / 60)    .. "m" end
  if diff < 86400     then return math.floor(diff / 3600)  .. "h" end
  if diff < 86400 * 30 then return math.floor(diff / 86400) .. "d" end
  if diff < 86400 * 365 then return math.floor(diff / 86400 / 30) .. "mo" end
  return math.floor(diff / 86400 / 365) .. "y"
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

  local pickers       = require("telescope.pickers")
  local finders       = require("telescope.finders")
  local conf          = require("telescope.config").values
  local actions       = require("telescope.actions")
  local action_state  = require("telescope.actions.state")
  local themes        = require("telescope.themes")
  local entry_display = require("telescope.pickers.entry_display")

  local max_id, max_proj, max_tags = 1, 1, 0
  for _, t in ipairs(tasks) do
    max_id   = math.max(max_id,   #tostring(t.id or ""))
    max_proj = math.max(max_proj, #(t.project or ""))
    max_tags = math.max(max_tags, #table.concat(t.tags or {}, ","))
  end
  max_proj = math.min(max_proj, 28)
  max_tags = math.min(max_tags, 16)

  local items = {
    { width = max_id },
    { width = 1 },
    { width = 1 },
    { width = max_proj },
    { remaining = true },
  }
  if max_tags > 0 then
    table.insert(items, { width = max_tags })
  end
  table.insert(items, { width = 4 })
  table.insert(items, { width = 7 })

  local displayer = entry_display.create({ separator = "  ", items = items })

  local function make_display(entry)
    local t = entry.value
    local cols = {
      { tostring(t.id or ""),                       "TelescopeResultsNumber" },
      { task_has_note(t)            and "●" or " ", "DiagnosticInfo" },
      { project_has_note(t.project) and "◆" or " ", "DiagnosticHint" },
      { (t.project or ""):sub(1, max_proj),         "Identifier" },
      { t.description or "",                        "TelescopeResultsNormal" },
    }
    if max_tags > 0 then
      table.insert(cols, { table.concat(t.tags or {}, ","):sub(1, max_tags), "Type" })
    end
    table.insert(cols, { age(t.entry),                            "Comment" })
    table.insert(cols, { string.format("(%.2f)", t.urgency or 0), "Number" })
    return displayer(cols)
  end

  pickers.new(themes.get_cursor({
    previewer = false,
    initial_mode = "normal",
    layout_config = { width = 100, height = math.min(#tasks + 4, 20) },
  }), {
    prompt_title = "Taskwarrior — pending tasks",
    finder = finders.new_table({
      results = tasks,
      entry_maker = function(task)
        local ordinal = table.concat({
          tostring(task.id or ""),
          task.project or "",
          task.description or "",
          table.concat(task.tags or {}, " "),
        }, " ")
        return { value = task, ordinal = ordinal, display = make_display }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local sel = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if sel then open_task_note(sel.value) end
      end)
      map({ "i", "n" }, "<C-p>", function()
        local sel = action_state.get_selected_entry()
        if not sel then return end
        local task = sel.value
        if not task.project or task.project == "" then
          vim.notify("Task has no project", vim.log.levels.WARN)
          return
        end
        actions.close(prompt_bufnr)
        open_project_note(task.project)
      end)
      return true
    end,
  }):find()
end

function M.setup()
  vim.api.nvim_create_user_command("TaskNotes", function() M.tasks() end, {})
end

return M
