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

M.vault = vim.fn.expand("~/notes")

-- Cache de los valores dinámicos escaneados del vault. Se refresca cada TTL
-- segundos para no re-leer todas las notas en cada disparo del autocompletado.
local TTL = 10
local dyn_cache = { values = nil, ts = 0 }

-- Escanea el bloque de frontmatter (`---` ... `---`) de cada nota del vault y
-- recolecta, por campo, el conjunto de valores usados. Soporta valores
-- escalares inline (`jira: SDO-235`) y listas YAML (`tags:` + `  - slalom`).
local function scan_vault()
	local values = {}
	local files = vim.fn.globpath(M.vault, "**/*.md", false, true)
	for _, file in ipairs(files) do
		local ok, lines = pcall(vim.fn.readfile, file, "", 60)
		if ok and lines[1] == "---" then
			local cur_key
			for i = 2, #lines do
				local line = lines[i]
				if line == "---" then
					break
				end
				local key, val = line:match("^(%w[%w_%-]*):%s*(.*)$")
				if key then
					cur_key = key
					val = vim.trim(val or "")
					if val ~= "" then
						values[key] = values[key] or {}
						values[key][val] = true
					end
				elseif cur_key then
					local item = line:match("^%s*%-%s+(.+)$")
					if item then
						item = vim.trim(item)
						if item ~= "" then
							values[cur_key] = values[cur_key] or {}
							values[cur_key][item] = true
						end
					end
				end
			end
		end
	end
	return values
end

-- Lista ordenada de valores usados en otras notas del vault para un campo.
function M.dynamic(key)
	local now = (vim.loop.now and vim.loop.now() or 0) / 1000
	if not dyn_cache.values or (now - dyn_cache.ts) > TTL then
		dyn_cache.values = scan_vault()
		dyn_cache.ts = now
	end
	local set = dyn_cache.values[key]
	if not set then
		return {}
	end
	local out = {}
	for v in pairs(set) do
		out[#out + 1] = v
	end
	table.sort(out)
	return out
end

-- Devuelve valores combinados (presets estáticos + usados en el vault),
-- sin duplicados y preservando primero los presets.
function M.values(key)
	local seen, out = {}, {}
	for _, v in ipairs(M.fields[key] or {}) do
		if not seen[v] then
			seen[v] = true
			out[#out + 1] = { value = v, dynamic = false }
		end
	end
	for _, v in ipairs(M.dynamic(key)) do
		if not seen[v] then
			seen[v] = true
			out[#out + 1] = { value = v, dynamic = true }
		end
	end
	return out
end

-- Fuerza el refresco del cache en el próximo M.dynamic()/M.values().
function M.invalidate()
	dyn_cache.values = nil
end

return M
