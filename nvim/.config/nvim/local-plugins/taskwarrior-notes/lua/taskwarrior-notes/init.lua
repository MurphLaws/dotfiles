-- taskwarrior-notes: snacks.picker table view of pending Taskwarrior tasks.
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

-- Convert a Taskwarrior ISO basic timestamp ("20260412T235345Z", UTC) to local epoch.
-- os.time() interprets the table as local time, so we add the local UTC offset to compensate.
local function iso_utc_to_epoch(iso)
  local y, mo, d, h, mi, s = iso:match("(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)Z")
  if not y then return nil end
  local as_local = os.time({
    year = tonumber(y), month = tonumber(mo), day = tonumber(d),
    hour = tonumber(h), min = tonumber(mi), sec = tonumber(s),
  })
  local now = os.time()
  local utc_offset = os.difftime(now, os.time(os.date("!*t", now)))
  return as_local + utc_offset
end

local function age(iso)
  if not iso then return "" end
  local t = iso_utc_to_epoch(iso)
  if not t then return "" end
  local diff = os.time() - t
  if diff < 0          then diff = 0                                      end
  if diff < 60         then return diff .. "s"                            end
  if diff < 3600       then return math.floor(diff / 60)    .. "m"        end
  if diff < 86400      then return math.floor(diff / 3600)  .. "h"        end
  if diff < 86400 * 30 then return math.floor(diff / 86400) .. "d"        end
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

  local Snacks = require("snacks")
  local align = Snacks.picker.util.align

  -- Build raw cell values for each row, then derive column widths.
  local rows = {}
  for _, t in ipairs(tasks) do
    rows[#rows + 1] = {
      task        = t,
      id          = tostring(t.id or ""),
      task_dot    = task_has_note(t)            and "●" or " ",
      proj_dot    = project_has_note(t.project) and "◆" or " ",
      project     = t.project or "",
      description = t.description or "",
      tags        = table.concat(t.tags or {}, ","),
      age         = age(t.entry),
      urgency     = string.format("%.2f", t.urgency or 0),
    }
  end

  local W = {
    id          = #"ID",
    task_dot    = #"T",
    proj_dot    = #"P",
    project     = #"PROJECT",
    description = #"DESCRIPTION",
    tags        = #"TAGS",
    age         = #"AGE",
    urgency     = #"URG",
  }
  local has_tags = false
  for _, r in ipairs(rows) do
    if #r.tags > 0 then has_tags = true end
    for k, v in pairs(W) do
      W[k] = math.max(v, vim.fn.strdisplaywidth(r[k] or ""))
    end
  end
  W.project     = math.min(W.project, 28)
  W.description = math.min(W.description, 50)
  W.tags        = math.min(W.tags, 16)
  W.urgency     = math.max(W.urgency, 5) -- "URG" or "12.34"

  local SEP = "  "

  -- Header row label per column. T = task-note marker, P = project-note marker.
  local HDR = {
    id          = "ID",
    task_dot    = "T",
    proj_dot    = "P",
    project     = "PROJECT",
    description = "DESCRIPTION",
    tags        = "TAGS",
    age         = "AGE",
    urgency     = "URG",
  }

  local function format(item)
    local r = item.is_header and HDR or item.row
    local hl = item.is_header and "Title" or nil
    local out = {}
    local function push(text, group, opts)
      out[#out + 1] = { align(text or "", opts.width, opts), hl or group }
      out[#out + 1] = { SEP }
    end
    push(r.id,          "Number",         { width = W.id, align = "right" })
    push(r.task_dot,    "DiagnosticInfo", { width = W.task_dot, align = "center" })
    push(r.proj_dot,    "DiagnosticHint", { width = W.proj_dot, align = "center" })
    push(r.project,     "Identifier",     { width = W.project, truncate = true })
    push(r.description, "Normal",         { width = W.description, truncate = true })
    if has_tags then
      push(r.tags,      "Type",           { width = W.tags, truncate = true })
    end
    push(r.age,         "Comment",        { width = W.age, align = "right" })
    out[#out + 1] = { align(r.urgency, W.urgency, { align = "right" }), hl or "Number" }
    return out
  end

  -- Items: header row first, then one per task. text drives fuzzy match (header excluded by score).
  local items = {
    { is_header = true, text = "", score = math.huge },
  }
  for _, r in ipairs(rows) do
    items[#items + 1] = {
      row = r,
      text = table.concat({ r.id, r.project, r.description, r.tags }, " "),
    }
  end

  local total_width =
      W.id + W.task_dot + W.proj_dot + W.project + W.description
      + (has_tags and W.tags or 0) + W.age + W.urgency
      + #SEP * (has_tags and 7 or 6)

  Snacks.picker.pick({
    source = "taskwarrior",
    title  = " Taskwarrior — pending tasks ",
    items  = items,
    format = format,
    focus  = "list",
    layout = {
      preview = false,
      hidden  = { "input", "preview" },
      layout  = {
        backdrop  = false,
        width     = math.min(total_width + 4, math.floor(vim.o.columns * 0.95)),
        height    = math.min(#items + 2, math.floor(vim.o.lines * 0.6)),
        min_width = 60,
        box       = "vertical",
        border    = "rounded",
        title     = "{title}",
        title_pos = "center",
        { win = "list", border = "none" },
      },
    },
    on_show = function(picker)
      -- Skip the header row on open.
      vim.schedule(function()
        if picker.list and picker.list.move then
          picker.list:move(2, true)
        end
      end)
    end,
    win = {
      list = {
        keys = {
          ["<C-p>"] = "open_project_note",
        },
      },
    },
    actions = {
      open_project_note = function(picker)
        local item = picker:current()
        if not item or item.is_header or not item.row then return end
        local task = item.row.task
        if not task.project or task.project == "" then
          vim.notify("Task has no project", vim.log.levels.WARN)
          return
        end
        picker:close()
        open_project_note(task.project)
      end,
    },
    confirm = function(picker, item)
      if not item or item.is_header or not item.row then
        return
      end
      picker:close()
      open_task_note(item.row.task)
    end,
  })
end

function M.setup()
  vim.api.nvim_create_user_command("TaskNotes", function() M.tasks() end, {})
end

return M
