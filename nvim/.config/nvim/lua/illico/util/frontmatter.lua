-- Valores conocidos de los campos del frontmatter de las notas.
-- Fuente única compartida por:
--   * el picker al crear tickets (illico/plugins/obsidian.lua)
--   * el source de autocompletado dentro del frontmatter
--     (illico/util/cmp_frontmatter.lua)
local M = {}

M.fields = {
	status = { "open", "in progress", "blocked", "in review", "done" },
	tags = { "slalom", "ticket", "meeting", "eda", "research", "spike", "bug" },
	type = { "ticket", "meeting", "note", "weekly", "person", "project" },
	owner = { "Nicolas" },
}

return M
