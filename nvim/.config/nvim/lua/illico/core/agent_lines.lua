-- ============================================================================
-- Diff vivo sobre el archivo abierto: qué se ha añadido y qué se ha quitado
-- desde que encendiste el marcador (`<leader>ta`).
--
--   * Línea con fondo VERDE  -> línea añadida o modificada.
--   * Línea ROJA tachada     -> línea que se quitó (se dibuja como línea
--                               virtual en el sitio que ocupaba; no existe en
--                               el archivo, solo se muestra).
--
-- No distingue quién lo hizo: compara el archivo contra la copia que se guardó
-- al encender, así que sirve igual para lo que escribe el agente y para lo que
-- escribes tú.
--
-- Por qué hay un temporizador: el agente puede escribir el archivo con la
-- herramienta de edición o con un comando de shell (`cat > archivo`). En el
-- segundo caso nadie avisa a Neovim, así que mientras el marcador está
-- encendido se hace `checktime` cada segundo para que el buffer se recargue y
-- el diff se repinte.
-- ============================================================================

local M = {}

local NS = vim.api.nvim_create_namespace("illico_agent_lines")
local GROUP = "illico_agent_lines"
local POLL_MS = 1000

local HL = {
    add = "IllicoDiffAddLine",
    delete = "IllicoDiffDeleteLine",
}

--- Contenido de referencia por buffer: contra esto se diffea.
--- @type table<integer, string[]>
local baselines = {}

--- @type uv.uv_timer_t|nil
local timer = nil

M.active = false

local function apply_highlights()
    vim.api.nvim_set_hl(0, HL.add, { bg = "#1f5c33" })
    vim.api.nvim_set_hl(
        0,
        HL.delete,
        { bg = "#5c1f28", fg = "#ffb0b0", strikethrough = true }
    )
end

--- Solo buffers de archivo normales: nada de los paneles del chat, terminales
--- ni scratch.
--- @param bufnr integer
--- @return boolean
local function is_trackable(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return false
    end

    if vim.bo[bufnr].buftype ~= "" then
        return false
    end

    if vim.bo[bufnr].filetype:match("^Agentic") then
        return false
    end

    return vim.api.nvim_buf_get_name(bufnr) ~= ""
end

--- @param bufnr integer
--- @return string[]
local function current_lines(bufnr)
    return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

--- Repinta el buffer entero desde cero. Recalcular sale más barato que llevar
--- la cuenta de qué marca corresponde a qué trozo, y evita marcas huérfanas.
--- @param bufnr integer
local function render(bufnr)
    if not M.active or not is_trackable(bufnr) then
        return
    end

    local base = baselines[bufnr]
    if not base then
        baselines[bufnr] = current_lines(bufnr)
        return
    end

    local after = current_lines(bufnr)

    pcall(vim.api.nvim_buf_clear_namespace, bufnr, NS, 0, -1)

    local ok, hunks = pcall(
        vim.text.diff,
        table.concat(base, "\n") .. "\n",
        table.concat(after, "\n") .. "\n",
        { result_type = "indices", algorithm = "histogram" }
    )

    if not ok or type(hunks) ~= "table" then
        return
    end

    local line_count = vim.api.nvim_buf_line_count(bufnr)

    for _, hunk in ipairs(hunks) do
        local start_a, count_a, start_b, count_b = unpack(hunk)

        -- Añadido o modificado: fondo verde en las líneas que están ahora.
        for row = start_b - 1, start_b + count_b - 2 do
            if row >= 0 and row < line_count then
                pcall(vim.api.nvim_buf_set_extmark, bufnr, NS, row, 0, {
                    line_hl_group = HL.add,
                    invalidate = true,
                })
            end
        end

        -- Quitado: las líneas ya no existen, así que se dibujan como líneas
        -- virtuales tachadas justo donde estaban.
        if count_a > 0 then
            --- @type string[][][]
            local virt_lines = {}

            for index = start_a, start_a + count_a - 1 do
                local text = base[index]
                if text then
                    virt_lines[#virt_lines + 1] =
                        { { text ~= "" and text or " ", HL.delete } }
                end
            end

            if #virt_lines > 0 then
                -- Ancla: la línea que ocupó su sitio, o la última del buffer
                -- cuando el recorte fue al final.
                local anchor = math.min(math.max(0, start_b - 1), line_count - 1)
                local above = count_b > 0 or start_b - 1 < line_count

                pcall(vim.api.nvim_buf_set_extmark, bufnr, NS, anchor, 0, {
                    virt_lines = virt_lines,
                    virt_lines_above = above,
                    invalidate = true,
                })
            end
        end
    end
end

local function render_all()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) and baselines[bufnr] then
            render(bufnr)
        end
    end
end

--- El agente puede escribir por fuera del editor (`cat > archivo`), y entonces
--- nadie avisa a Neovim. Esto fuerza la comprobación mientras está encendido.
local function start_polling()
    if timer then
        return
    end

    timer = vim.uv.new_timer()

    if not timer then
        return
    end

    timer:start(
        POLL_MS,
        POLL_MS,
        vim.schedule_wrap(function()
            if not M.active then
                return
            end

            -- Solo buffers sin cambios propios: un `checktime` sobre un
            -- buffer modificado cuyo archivo cambió en disco lanza el aviso
            -- W12 y te interrumpe. Los tuyos ya se repintan por TextChanged.
            for bufnr, _ in pairs(baselines) do
                if
                    vim.api.nvim_buf_is_valid(bufnr)
                    and not vim.bo[bufnr].modified
                then
                    pcall(vim.cmd, "checktime " .. bufnr)
                end
            end

            render_all()
        end)
    )
end

local function stop_polling()
    if timer then
        timer:stop()
        timer:close()
        timer = nil
    end
end

function M.enable()
    if M.active then
        return
    end

    M.active = true
    apply_highlights()

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) and is_trackable(bufnr) then
            baselines[bufnr] = current_lines(bufnr)
        end
    end

    local group = vim.api.nvim_create_augroup(GROUP, { clear = true })

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
        group = group,
        desc = "Fija la referencia de un buffer que se abre después",
        callback = function(ev)
            if not baselines[ev.buf] and is_trackable(ev.buf) then
                baselines[ev.buf] = current_lines(ev.buf)
            else
                render(ev.buf)
            end
        end,
    })

    vim.api.nvim_create_autocmd({
        "TextChanged",
        "TextChangedI",
        "InsertLeave",
        "FileChangedShellPost",
    }, {
        group = group,
        desc = "Repinta el diff tras cualquier cambio",
        callback = function(ev)
            render(ev.buf)
        end,
    })

    vim.api.nvim_create_autocmd("BufDelete", {
        group = group,
        callback = function(ev)
            baselines[ev.buf] = nil
        end,
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        desc = "Repone los colores del diff tras cambiar de tema",
        callback = apply_highlights,
    })

    start_polling()
    render_all()
end

function M.disable()
    if not M.active then
        return
    end

    M.active = false
    stop_polling()
    pcall(vim.api.nvim_del_augroup_by_name, GROUP)

    for bufnr, _ in pairs(baselines) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            pcall(vim.api.nvim_buf_clear_namespace, bufnr, NS, 0, -1)
        end
    end

    baselines = {}
end

--- @return boolean active
function M.toggle()
    if M.active then
        M.disable()
    else
        M.enable()
    end

    return M.active
end

--- Vuelve a fijar la referencia en el buffer actual: lo que hay ahora pasa a
--- ser "sin cambios" y el diff queda limpio.
function M.reset()
    local bufnr = vim.api.nvim_get_current_buf()

    if not M.active then
        vim.notify("El diff está apagado.", vim.log.levels.INFO)
        return
    end

    baselines[bufnr] = current_lines(bufnr)
    pcall(vim.api.nvim_buf_clear_namespace, bufnr, NS, 0, -1)
    vim.notify("Referencia del diff reiniciada en este buffer.", vim.log.levels.INFO)
end

--- Qué está viendo el buffer actual, para no adivinar.
function M.report()
    if not M.active then
        vim.notify(
            "Diff apagado (`<leader>ta` para encenderlo).",
            vim.log.levels.INFO
        )
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local marks =
        vim.api.nvim_buf_get_extmarks(bufnr, NS, 0, -1, { details = true })

    local added, removed = 0, 0

    for _, extmark in ipairs(marks) do
        local details = extmark[4] or {}

        if details.line_hl_group == HL.add then
            added = added + 1
        end

        if details.virt_lines then
            removed = removed + #details.virt_lines
        end
    end

    vim.notify(
        string.format(
            "Diff activo | referencia: %s | %d líneas añadidas o modificadas, %d quitadas",
            baselines[bufnr] and (#baselines[bufnr] .. " líneas") or "sin fijar",
            added,
            removed
        ),
        vim.log.levels.INFO
    )
end

function M.setup()
    apply_highlights()

    vim.keymap.set("n", "<leader>ta", function()
        vim.notify(
            "Diff sobre el archivo: "
                .. (M.toggle() and "activado" or "apagado"),
            vim.log.levels.INFO
        )
    end, { desc = "Toggle diff vivo sobre el archivo (verde/rojo)" })

    vim.keymap.set(
        "n",
        "<leader>ti",
        M.report,
        { desc = "Diff sobre el archivo: info" }
    )

    vim.keymap.set(
        "n",
        "<leader>tr",
        M.reset,
        { desc = "Diff sobre el archivo: refijar referencia" }
    )
end

return M
