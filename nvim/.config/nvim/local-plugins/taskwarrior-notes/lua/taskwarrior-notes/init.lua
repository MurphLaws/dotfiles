-- taskwarrior-notes: snacks.picker table view of pending Taskwarrior tasks.
-- Storage layout:
--   task notes:    ~/.task/notes/<uuid>.norg
--   project notes: ~/.task/notes/projects/<project>.norg
--   project links: ~/.task/notes/projects/<project>.link  (single-line text)
--   task links:    `link` UDA on the task

local M = {}

local NOTE_DIR = vim.fn.expand("~/.task/notes")
local PROJECT_NOTE_DIR = NOTE_DIR .. "/projects"

-- Nerd Font icons (PUA codepoints) — written as byte escapes so the source
-- stays ASCII even through editors that strip PUA glyphs.
local ICON_NOTE    = "\xEF\x85\x9B"  -- U+F15B nf-fa-file
local ICON_PROJECT = "\xEF\x84\x94"  -- U+F114 nf-fa-folder
local ICON_LINK    = "\xEF\x83\x81"  -- U+F0C1 nf-fa-link  (task link, yellow)
local ICON_PLINK   = "\xEF\x83\x81"  -- U+F0C1 nf-fa-link  (project link, green)

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

local function project_link_file(project)
  return PROJECT_NOTE_DIR .. "/" .. project .. ".link"
end

local function project_has_link(project)
  if not project or project == "" then return false end
  return vim.fn.filereadable(project_link_file(project)) == 1
end

local function read_project_link(project)
  if not project_has_link(project) then return nil end
  local lines = vim.fn.readfile(project_link_file(project))
  if not lines or #lines == 0 then return nil end
  local v = vim.trim(lines[1])
  return v ~= "" and v or nil
end

local function write_project_link(project, value)
  ensure_dirs()
  vim.fn.writefile({ value }, project_link_file(project))
end

local function task_has_link(task)
  return type(task.link) == "string" and vim.trim(task.link) ~= ""
end

local function clipboard()
  local v = vim.fn.getreg("+")
  if not v or v == "" then v = vim.fn.getreg("*") end
  return vim.trim(v or "")
end

local function resolve_link_value(value)
  if value:match("^%a+://") or value:sub(1, 1) == "/" then
    return value
  end
  local expanded = vim.fn.expand(value)
  if vim.fn.filereadable(expanded) == 1 or vim.fn.isdirectory(expanded) == 1 then
    return vim.fn.fnamemodify(expanded, ":p")
  end
  return value
end

local function open_url_or_path(value)
  if vim.ui and type(vim.ui.open) == "function" then
    vim.ui.open(value)
  else
    vim.fn.jobstart({ "open", value }, { detach = true })
  end
end

local function set_task_link(uuid, value)
  vim.fn.system({
    "task", "rc.confirmation=no", "rc.verbose=nothing",
    uuid, "modify", "link:" .. value,
  })
end

local function delete_task_link(uuid)
  vim.fn.system({
    "task", "rc.confirmation=no", "rc.verbose=nothing",
    uuid, "modify", "link:",
  })
end

local function delete_project_link(project)
  if project_has_link(project) then
    vim.fn.delete(project_link_file(project))
  end
end

local function task_note_path(uuid)
  return NOTE_DIR .. "/" .. uuid .. ".norg"
end

local function delete_task_note(uuid)
  local p = task_note_path(uuid)
  if vim.fn.filereadable(p) == 1 then
    vim.fn.delete(p)
  end
  vim.fn.system({ "task", "rc.confirmation=no", "rc.verbose=nothing", uuid, "modify", "note:" })
end

local function delete_project_note(project)
  local p = PROJECT_NOTE_DIR .. "/" .. project .. ".norg"
  if vim.fn.filereadable(p) == 1 then
    vim.fn.delete(p)
  end
end

local function confirm(prompt)
  local ans = vim.fn.input(prompt .. " [y/N] ")
  return ans:lower():sub(1, 1) == "y"
end

local function ensure_highlights()
  -- Match the TUI's truecolor palette for link icons.
  vim.api.nvim_set_hl(0, "TaskwarriorLink",  { fg = "#FFCA58", default = true })
  vim.api.nvim_set_hl(0, "TaskwarriorPlink", { fg = "#BCDF59", default = true })
  -- White cursorline on the current selection (mirrors the TUI's bg+).
  vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { bg = "#FFFFFF", fg = "NONE" })
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

  ensure_highlights()

  local Snacks = require("snacks")
  local align = Snacks.picker.util.align

  -- Keybind hint line shown above the column header (mirrors the TUI's --header).
  local HINTS = "  ⏎ note  ·  p proj-note  ·  o/l task link  ·  O/L project link"
                .. "  ·  D delete…  ·  q close"

  -- Build raw cell values for each row, then derive column widths.
  local rows = {}
  for _, t in ipairs(tasks) do
    local proj = t.project or ""
    rows[#rows + 1] = {
      task        = t,
      id          = tostring(t.id or ""),
      icon_note   = task_has_note(t)        and ICON_NOTE    or " ",
      icon_proj   = project_has_note(proj)  and ICON_PROJECT or " ",
      icon_link   = task_has_link(t)        and ICON_LINK    or " ",
      icon_plink  = project_has_link(proj)  and ICON_PLINK   or " ",
      project     = proj,
      description = t.description or "",
      tags        = table.concat(t.tags or {}, ","),
      age         = age(t.entry),
      urgency     = string.format("%.2f", t.urgency or 0),
    }
  end

  local W = {
    id          = #"ID",
    icon_note   = 1,
    icon_proj   = 1,
    icon_link   = 1,
    icon_plink  = 1,
    project     = #"PROJECT",
    description = #"DESCRIPTION",
    tags        = #"TAGS",
    age         = #"AGE",
    urgency     = #"URG",
  }
  for _, r in ipairs(rows) do
    for k, v in pairs(W) do
      W[k] = math.max(v, vim.fn.strdisplaywidth(r[k] or ""))
    end
  end
  W.project     = math.min(W.project, 28)
  W.description = math.min(W.description, 50)
  W.tags        = math.min(W.tags, 16)
  W.urgency     = math.max(W.urgency, 5)

  local SEP = "  "

  -- Header row labels — icon columns intentionally have no label.
  local HDR = {
    id          = "ID",
    icon_note   = "",
    icon_proj   = "",
    icon_link   = "",
    icon_plink  = "",
    project     = "PROJECT",
    description = "DESCRIPTION",
    tags        = "TAGS",
    age         = "AGE",
    urgency     = "URG",
  }

  local function format(item)
    if item.is_help then
      return { { HINTS, "Comment" } }
    end
    local r = item.is_header and HDR or item.row
    local hl = item.is_header and "Title" or nil
    local out = {}
    local function push(text, group, opts)
      out[#out + 1] = { align(text or "", opts.width, opts), hl or group }
      out[#out + 1] = { SEP }
    end
    push(r.id,          "Number",         { width = W.id,          align = "right" })
    push(r.icon_note,   "DiagnosticInfo", { width = W.icon_note,   align = "center" })
    push(r.icon_proj,   "Constant",       { width = W.icon_proj,   align = "center" })
    push(r.icon_link,   "TaskwarriorLink",  { width = W.icon_link,   align = "center" })
    push(r.icon_plink,  "TaskwarriorPlink", { width = W.icon_plink,  align = "center" })
    push(r.project,     "Identifier",     { width = W.project,     truncate = true })
    push(r.description, "Normal",         { width = W.description, truncate = true })
    push(r.tags,        "Type",           { width = W.tags,        truncate = true })
    push(r.age,         "Comment",        { width = W.age,         align = "right" })
    out[#out + 1] = { align(r.urgency, W.urgency, { align = "right" }), hl or "Number" }
    return out
  end

  -- Items: keybind hints, column header, then one per task. The hints/header
  -- are pinned at the top via score = math.huge and skipped by selection logic.
  local items = {
    { is_help   = true, text = "", score = math.huge + 1 },
    { is_header = true, text = "", score = math.huge },
  }
  for _, r in ipairs(rows) do
    items[#items + 1] = {
      row = r,
      text = table.concat({ r.id, r.project, r.description, r.tags }, " "),
    }
  end

  local total_width =
      W.id + W.icon_note + W.icon_proj + W.icon_link + W.icon_plink
      + W.project + W.description + W.tags + W.age + W.urgency
      + #SEP * 9

  Snacks.picker.pick({
    source = "taskwarrior",
    title  = " Taskwarrior — pending tasks ",
    items  = items,
    format = format,
    focus  = "list",
    layout = {
      preview = false,
      hidden  = { "preview" },
      layout  = {
        backdrop  = false,
        width     = math.min(total_width + 4, math.floor(vim.o.columns * 0.95)),
        height    = math.min(#items + 3, math.floor(vim.o.lines * 0.6)),
        min_width = 60,
        box       = "vertical",
        border    = "rounded",
        title     = "{title} {live} {flags}",
        title_pos = "center",
        { win = "input", height = 1, border = "bottom" },
        { win = "list",  border = "none" },
      },
    },
    on_show = function(picker)
      -- Skip the keybind-hints + column-header rows on open.
      vim.schedule(function()
        if picker.list and picker.list.move then
          picker.list:move(3, true)
        end
      end)
    end,
    win = {
      list = {
        keys = {
          ["p"] = "open_project_note",
          ["o"] = "open_task_link",
          ["l"] = "set_task_link",
          ["O"] = "open_project_link",
          ["L"] = "set_project_link",
          ["D"] = "delete_menu",
        },
      },
      input = {
        keys = {
          -- Insert-mode equivalents (the literal letters would just be typed).
          ["<c-y>"] = { "open_project_note",  mode = { "i", "n" } },
          ["<c-o>"] = { "open_task_link",     mode = { "i", "n" } },
          ["<c-l>"] = { "set_task_link",      mode = { "i", "n" } },
        },
      },
    },
    actions = {
      open_project_note = function(picker)
        local item = picker:current()
        if not item or item.is_help or item.is_header or not item.row then return end
        local task = item.row.task
        if not task.project or task.project == "" then
          vim.notify("Task has no project", vim.log.levels.WARN)
          return
        end
        picker:close()
        open_project_note(task.project)
      end,
      open_task_link = function(picker)
        local item = picker:current()
        if not item or item.is_help or item.is_header or not item.row then return end
        local task = item.row.task
        if not task_has_link(task) then
          vim.notify("Task has no link (press l to set one from clipboard)", vim.log.levels.WARN)
          return
        end
        picker:close()
        open_url_or_path(vim.trim(task.link))
      end,
      set_task_link = function(picker)
        local item = picker:current()
        if not item or item.is_help or item.is_header or not item.row then return end
        local value = clipboard()
        if value == "" then
          vim.notify("Clipboard is empty — nothing to set", vim.log.levels.WARN)
          return
        end
        value = resolve_link_value(value)
        set_task_link(item.row.task.uuid, value)
        vim.notify("Task link set: " .. value, vim.log.levels.INFO)
        picker:close()
        vim.schedule(function() M.tasks() end) -- reopen so the new icon shows
      end,
      open_project_link = function(picker)
        local item = picker:current()
        if not item or item.is_help or item.is_header or not item.row then return end
        local proj = item.row.task.project or ""
        if proj == "" then
          vim.notify("Task has no project", vim.log.levels.WARN)
          return
        end
        local link = read_project_link(proj)
        if not link then
          vim.notify(
            ("Project '%s' has no link (press L to set one from clipboard)"):format(proj),
            vim.log.levels.WARN
          )
          return
        end
        picker:close()
        open_url_or_path(link)
      end,
      set_project_link = function(picker)
        local item = picker:current()
        if not item or item.is_help or item.is_header or not item.row then return end
        local proj = item.row.task.project or ""
        if proj == "" then
          vim.notify("Task has no project — cannot set project link", vim.log.levels.WARN)
          return
        end
        local value = clipboard()
        if value == "" then
          vim.notify("Clipboard is empty — nothing to set", vim.log.levels.WARN)
          return
        end
        value = resolve_link_value(value)
        write_project_link(proj, value)
        vim.notify(("Project '%s' link set: %s"):format(proj, value), vim.log.levels.INFO)
        picker:close()
        vim.schedule(function() M.tasks() end) -- reopen so the new icon shows
      end,
      delete_menu = function(picker)
        local item = picker:current()
        if not item or item.is_help or item.is_header or not item.row then return end
        local task = item.row.task
        local proj = task.project or ""

        local choices = {}
        if task_has_note(task) then
          table.insert(choices, { id = "note", label = "Task note" })
        end
        if proj ~= "" and project_has_note(proj) then
          table.insert(choices, { id = "pnote", label = "Project note  (" .. proj .. ")" })
        end
        if task_has_link(task) then
          local link = vim.trim(task.link or "")
          table.insert(choices, { id = "link", label = "Task link  (" .. link:sub(1, 60) .. ")" })
        end
        if proj ~= "" and project_has_link(proj) then
          local link = read_project_link(proj) or ""
          table.insert(choices, { id = "plink",
            label = "Project link  (" .. proj .. " → " .. link:sub(1, 50) .. ")" })
        end

        if #choices == 0 then
          vim.notify("Nothing to delete on this task", vim.log.levels.INFO)
          return
        end

        vim.ui.select(choices, {
          prompt = "Delete what?",
          format_item = function(c) return c.label end,
        }, function(choice)
          if not choice then return end
          local needs_confirm = choice.id == "note" or choice.id == "pnote"
          if needs_confirm and not confirm("Delete " .. choice.label .. "?") then
            return
          end
          if     choice.id == "note"  then delete_task_note(task.uuid)
          elseif choice.id == "pnote" then delete_project_note(proj)
          elseif choice.id == "link"  then delete_task_link(task.uuid)
          elseif choice.id == "plink" then delete_project_link(proj)
          end
          vim.notify("Deleted: " .. choice.label, vim.log.levels.INFO)
          picker:close()
          vim.schedule(function() M.tasks() end)
        end)
      end,
    },
    confirm = function(picker, item)
      if not item or item.is_help or item.is_header or not item.row then
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
