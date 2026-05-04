-- Hierarchical cycle for thenbe/markdown-todo.nvim. Toggles done/undone with:
--   * cascade: parent toggle propagates to all descendants
--   * rollup:  ancestors auto-derive state and stat-line "<done>/<total> <pct>%"
-- Indicator format follows the plugin: "(x)" done, "( )" undone.

local M = {}

local INDICATOR = "%(%s?[%s%-_=xy!+?o]%s?%)"
local STATS_TAIL = "%s*%d+/%d+%s+%d+%%%s*$"

local function get_indent(line)
  return #(line:match("^(%s*)") or "")
end

local function todo_state(line)
  local marker = line:match("%(%s?([%s%-_=xy!+?o])%s?%)")
  if not marker then return nil end
  if marker == "x" or marker == "X" then return "done" end
  if marker == " " then return "undone" end
  return "other"
end

local function set_state(lines, idx, state)
  local replacement = (state == "done") and "(x)" or "( )"
  lines[idx] = (lines[idx]:gsub(INDICATOR, replacement, 1))
end

local function direct_children(lines, parent_idx)
  local parent_indent = get_indent(lines[parent_idx])
  local children = {}
  local child_indent = nil
  for i = parent_idx + 1, #lines do
    local line = lines[i]
    if not line:match("^%s*$") then
      local indent = get_indent(line)
      if indent <= parent_indent then break end
      if todo_state(line) ~= nil then
        if not child_indent then child_indent = indent end
        if indent == child_indent then
          table.insert(children, i)
        end
      end
    end
  end
  return children
end

local function descendants(lines, parent_idx)
  local parent_indent = get_indent(lines[parent_idx])
  local result = {}
  for i = parent_idx + 1, #lines do
    local line = lines[i]
    if not line:match("^%s*$") then
      local indent = get_indent(line)
      if indent <= parent_indent then break end
      if todo_state(line) ~= nil then
        table.insert(result, i)
      end
    end
  end
  return result
end

local function ancestors(lines, idx)
  local current_indent = get_indent(lines[idx])
  local result = {}
  for i = idx - 1, 1, -1 do
    local line = lines[i]
    if not line:match("^%s*$") then
      local indent = get_indent(line)
      if indent < current_indent and todo_state(line) ~= nil then
        table.insert(result, i)
        current_indent = indent
        if indent == 0 then break end
      end
    end
  end
  return result
end

local function update_parent(lines, idx)
  local children = direct_children(lines, idx)
  if #children == 0 then return end
  local total = #children
  local done = 0
  for _, ci in ipairs(children) do
    if todo_state(lines[ci]) == "done" then
      done = done + 1
    end
  end
  local pct = math.floor(done * 100 / total)
  local stats = string.format("%d/%d %d%%", done, total, pct)
  local stripped = lines[idx]:gsub(STATS_TAIL, ""):gsub("%s+$", "")
  lines[idx] = stripped .. " " .. stats
  set_state(lines, idx, (done == total) and "done" or "undone")
end

function M.cycle()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local idx = cursor_row

  if not lines[idx] or todo_state(lines[idx]) == nil then
    -- No indicator yet: defer to plugin to add one (it inserts "( )").
    require("markdown-todo").make_todo("undone")
    lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    if todo_state(lines[idx]) == nil then return end
  end

  local target = (todo_state(lines[idx]) == "done") and "undone" or "done"
  set_state(lines, idx, target)

  for _, di in ipairs(descendants(lines, idx)) do
    set_state(lines, di, target)
  end

  update_parent(lines, idx)

  for _, ai in ipairs(ancestors(lines, idx)) do
    update_parent(lines, ai)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, { cursor_row, 0 })
end

return M
