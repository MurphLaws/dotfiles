local PORT = 7777
local CTRL_PORT = PORT + 1 -- canal de control del visor para el forward-sync
local URL = "http://127.0.0.1:" .. PORT
local SRC = vim.fn.expand("~/.tmux/scripts/qpreview.swift")
local BIN = vim.fn.expand("~/.cache/quarto-preview/qpreview")
local TILE = vim.fn.expand("~/.tmux/scripts/quarto-tile.sh")

-- Python para el motor Jupyter de quarto. nvim suele correr DENTRO de un env
-- conda (p. ej. nvim-py) cuyo python NO tiene las dependencias de quarto
-- (nbclient, nbformat…) ni el kernel `python3`; si quarto usa ese python falla
-- con "kernel 'python3' not found" o "No module named 'nbclient'". Por eso le
-- forzamos un python completo vía QUARTO_PYTHON. Se respeta un override del
-- entorno; si no, se toma el primer candidato que exista en disco.
local function resolve_quarto_python()
  if vim.env.QUARTO_PYTHON and vim.env.QUARTO_PYTHON ~= "" then
    return vim.env.QUARTO_PYTHON
  end
  for _, p in ipairs({
    "/opt/miniconda3/bin/python",
    "/opt/homebrew/bin/python3",
    "/usr/bin/python3",
  }) do
    if vim.fn.filereadable(p) == 1 then
      return p
    end
  end
  return nil
end
local QUARTO_PYTHON = resolve_quarto_python()

local state = { job = nil, viewer = nil, file = nil, bufnr = nil }

-- Forward-sync: al mover el cursor en el .qmd, centra en el preview la sección
-- del encabezado más cercano por encima del cursor. No es línea-a-línea como
-- SyncTeX (el render es HTML, no hay mapa línea↔píxel), sino a nivel de sección.
local sync = { timer = nil, last = nil }

-- Devuelve (texto_encabezado, ocurrencia) del heading más cercano en o por
-- encima del cursor. Ignora los `#` dentro de bloques de código cercados. La
-- ocurrencia (1-based) desempata headings con texto idéntico.
local function current_heading()
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(state.bufnr, 0, cur, false)
  local in_fence = false
  local heading, count, counts = nil, 0, {}
  for _, l in ipairs(lines) do
    if l:match("^%s*[`~][`~][`~]") then
      in_fence = not in_fence
    elseif not in_fence then
      local h = l:match("^#+%s+(.+)$")
      if h then
        h = h:gsub("%s*{[^}]*}%s*$", "") -- quita {#id .clase} al final
        h = h:gsub("%s+#+%s*$", "")        -- quita ### de cierre estilo atx
        h = vim.trim(h)
        if h ~= "" then
          counts[h] = (counts[h] or 0) + 1
          heading, count = h, counts[h]
        end
      end
    end
  end
  return heading, count
end

local function send_scroll()
  if not (state.job and state.viewer) then return end
  if vim.api.nvim_get_current_buf() ~= state.bufnr then return end
  local h, n = current_heading()
  if not h then return end
  local key = n .. "\31" .. h
  if key == sync.last then return end
  sync.last = key
  local url = string.format(
    "http://127.0.0.1:%d/scroll?n=%d&text=%s", CTRL_PORT, n, vim.uri_encode(h)
  )
  vim.fn.jobstart({ "curl", "-s", "-m", "1", url }, { detach = true })
end

-- Autocmds que cierran el preview cuando el buffer del .qmd desaparece, para
-- que nvim recupere todo el ancho sin tener que llamar :QuartoSplitClose a mano.
local AUGROUP = vim.api.nvim_create_augroup("QuartoSplitAuto", { clear = true })

local function notify(msg, level)
  vim.notify("[QuartoSplit] " .. msg, level or vim.log.levels.INFO)
end

local function fail(msg)
  notify(msg, vim.log.levels.ERROR)
end

local function tmux(...)
  vim.fn.system({ "tmux", ... })
end

local function in_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

-- Indicador de carga: ventana flotante animada en la esquina inferior-derecha.
local SPINNER = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spin = { timer = nil, win = nil, buf = nil, n = 0 }

local function spinner_stop()
  if spin.timer then
    vim.fn.timer_stop(spin.timer)
    spin.timer = nil
  end
  if spin.win and vim.api.nvim_win_is_valid(spin.win) then
    vim.api.nvim_win_close(spin.win, true)
  end
  spin.win = nil
  if spin.buf and vim.api.nvim_buf_is_valid(spin.buf) then
    vim.api.nvim_buf_delete(spin.buf, { force = true })
  end
  spin.buf = nil
end

-- Arranca el spinner. timeout_s/on_timeout son opcionales: si pasa ese tiempo
-- sin que se llame spinner_stop(), se cierra solo y dispara on_timeout().
local function spinner_start(label, timeout_s, on_timeout)
  spinner_stop()
  spin.n = 0
  spin.buf = vim.api.nvim_create_buf(false, true)
  spin.win = vim.api.nvim_open_win(spin.buf, false, {
    relative = "editor",
    anchor = "SE",
    row = vim.o.lines - 2,
    col = vim.o.columns - 1,
    width = vim.fn.strdisplaywidth(label) + 12,
    height = 1,
    style = "minimal",
    border = "rounded",
    focusable = false,
    noautocmd = true,
    zindex = 200,
  })
  vim.api.nvim_set_option_value(
    "winhighlight",
    "Normal:DiagnosticInfo,FloatBorder:DiagnosticInfo",
    { win = spin.win }
  )

  local function render()
    if not (spin.buf and vim.api.nvim_buf_is_valid(spin.buf)) then
      return
    end
    local frame = SPINNER[(spin.n % #SPINNER) + 1]
    local secs = math.floor(spin.n / 10)
    vim.api.nvim_buf_set_lines(spin.buf, 0, -1, false, {
      string.format(" %s %s (%ds)", frame, label, secs),
    })
  end

  render()
  spin.timer = vim.fn.timer_start(100, function()
    spin.n = spin.n + 1
    if timeout_s and spin.n >= timeout_s * 10 then
      spinner_stop()
      if on_timeout then on_timeout() end
      return
    end
    render()
  end, { ["repeat"] = -1 })
end

local function ensure_viewer()
  if vim.fn.executable("swiftc") == 0 then
    fail("no encuentro `swiftc` (instala las Command Line Tools de Xcode)")
    return false
  end
  if vim.fn.filereadable(BIN) == 1 and vim.fn.getftime(BIN) >= vim.fn.getftime(SRC) then
    return true
  end
  vim.fn.mkdir(vim.fn.fnamemodify(BIN, ":h"), "p")
  notify("compilando el visor WebKit (solo esta vez) …")
  local out = vim.fn.system({ "swiftc", "-O", SRC, "-o", BIN })
  if vim.v.shell_error ~= 0 then
    fail("falló la compilación del visor:\n" .. out)
    return false
  end
  return true
end

-- Abre el visor WebKit y aplica el tiling. Se llama UNA sola vez, cuando el
-- server ya respondió. Va envuelto en vim.schedule por los callbacks de job.
local function launch_viewer_and_tile()
  spinner_stop()
  state.viewer = vim.fn.jobstart({ BIN, state.url or URL, "right", tostring(CTRL_PORT) }, {
    on_exit = function() state.viewer = nil end,
  })
  if state.viewer <= 0 then
    state.viewer = nil
    return fail("no pude arrancar el visor WebKit")
  end

  if in_tmux() then
    tmux("set-option", "-g", "@quarto_active", "1")
    tmux("set-option", "-w", "@quarto_tile", "1")
    vim.fn.system({ "bash", TILE })
    notify("split listo (Ghostty izq. / visor der.)")
  else
    notify("preview abierto; sin tmux no hay tiling automático de Ghostty")
  end
end

-- forward declaration: open() registra un autocmd que llama a close()
local close

-- Libera los puertos de un preview/visor huérfano (p. ej. si nvim se recargó o
-- crasheó y perdió los handles de los jobs). Sin esto, quarto aborta el arranque
-- con "Requested port 7777 is already in use".
local function free_ports()
  local killed = false
  for _, p in ipairs({ PORT, CTRL_PORT }) do
    for _, pid in ipairs(vim.fn.systemlist({ "lsof", "-ti", "tcp:" .. p })) do
      if pid ~= "" then
        vim.fn.system({ "kill", pid })
        killed = true
      end
    end
  end
  if killed then
    -- `kill` envía SIGTERM y vuelve enseguida; espera a que el SO libere el
    -- puerto antes de relanzar quarto (máx. ~1s, sale en cuanto está libre).
    vim.wait(1000, function()
      return #vim.fn.systemlist({ "lsof", "-ti", "tcp:" .. PORT }) == 0
    end, 50)
  end
end

local function open()
  if state.job then
    notify("ya hay un preview activo (usa :QuartoSplitClose primero)", vim.log.levels.WARN)
    return
  end
  local file = vim.fn.expand("%:p")
  if file == "" then
    return fail("el buffer no tiene archivo en disco")
  end
  if vim.fn.executable("quarto") == 0 then
    return fail("no encuentro `quarto` en PATH")
  end
  if not ensure_viewer() then
    return
  end
  free_ports()
  state.file = file
  state.bufnr = vim.api.nvim_get_current_buf()
  state.launched = false
  state.url = nil
  state.output = {}

  -- Cerrar el .qmd (:bd/:bw, :q de su ventana, o salir de nvim) restaura el
  -- layout automáticamente: nvim vuelve a ocupar todo el ancho.
  vim.api.nvim_clear_autocmds({ group = AUGROUP })
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "QuitPre" }, {
    group = AUGROUP,
    buffer = state.bufnr,
    callback = function()
      if state.job then
        vim.schedule(close)
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = AUGROUP,
    callback = function()
      if state.job then close() end
    end,
  })

  -- Forward-sync: con debounce (~150 ms) para no inundar el visor con curls.
  sync.last = nil
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = AUGROUP,
    buffer = state.bufnr,
    callback = function()
      if sync.timer then vim.fn.timer_stop(sync.timer) end
      sync.timer = vim.fn.timer_start(150, function()
        vim.schedule(send_scroll)
      end)
    end,
  })

  -- Detecta de forma NO bloqueante que el server está listo leyendo la salida
  -- de `quarto preview` ("Listening on …" / "Browse at …"). Antes se usaba
  -- vim.wait(60000), que congela toda la UI de nvim durante el arranque en
  -- frío (~20s) — por eso "se quedaba pegado". De paso guardamos la salida
  -- para poder mostrar el error real de quarto si falla.
  local function watch(_, data)
    if not data then return end
    for _, line in ipairs(data) do
      if line ~= "" then
        table.insert(state.output, line)
      end
      -- En modo proyecto (_quarto.yml) quarto sirve el doc en /archivo.html, no
      -- en la raíz; "Browse at <url>" trae la URL real. La capturamos (limpiando
      -- códigos ANSI) para que el visor abra esa página y no un 404 en "/".
      local clean = line:gsub("\27%[[%d;]*m", "")
      local url = clean:match("Browse at%s+(https?://%S+)")
      if url then
        state.url = url:gsub("localhost", "127.0.0.1")
      end
      if not state.launched and (clean:find("Listening on", 1, true) or clean:find("Browse at", 1, true)) then
        state.launched = true
        vim.schedule(launch_viewer_and_tile)
      end
    end
  end

  -- Última línea de error útil de la salida de quarto (para el aviso).
  local function last_error()
    for i = #state.output, 1, -1 do
      local l = state.output[i]:gsub("\27%[%d*m", "") -- limpia códigos ANSI
      if l:find("ERROR", 1, true) or l:find("Error", 1, true) then
        return l
      end
    end
    return state.output[#state.output]
  end

  spinner_start("Quarto: arrancando preview", 90, function()
    if state.job then
      vim.fn.jobstop(state.job)
      state.job = nil
    end
    fail("el server no respondió a tiempo (90s)")
  end)
  state.job = vim.fn.jobstart(
    { "quarto", "preview", file, "--port", tostring(PORT), "--no-browser" },
    {
      env = QUARTO_PYTHON and { QUARTO_PYTHON = QUARTO_PYTHON } or nil,
      on_stdout = watch,
      on_stderr = watch,
      on_exit = function(_, code)
        state.job = nil
        if not state.launched then
          vim.schedule(function()
            spinner_stop()
            local err = last_error()
            local msg = "quarto preview falló (código " .. code .. ")"
            if err then
              msg = msg .. ":\n" .. err
            end
            fail(msg)
          end)
        end
      end,
    }
  )
  if state.job <= 0 then
    state.job = nil
    spinner_stop()
    return fail("no pude arrancar `quarto preview`")
  end
end

close = function()
  vim.api.nvim_clear_autocmds({ group = AUGROUP })
  if sync.timer then
    vim.fn.timer_stop(sync.timer)
    sync.timer = nil
  end
  sync.last = nil
  spinner_stop()
  if state.job then
    vim.fn.jobstop(state.job)
    state.job = nil
  end
  if state.viewer then
    vim.fn.jobstop(state.viewer)
    state.viewer = nil
  end
  if in_tmux() then
    tmux("set-option", "-wu", "@quarto_tile")
    tmux("set-option", "-g", "@quarto_active", "1")
    vim.fn.system({ "bash", TILE })
    tmux("set-option", "-gu", "@quarto_active")
  end
  state.file = nil
  state.bufnr = nil
  notify("preview cerrado y layout restaurado")
end

vim.api.nvim_create_user_command("QuartoSplit", open, { desc = "Quarto preview en split (nvim izq / visor WebKit der)" })
vim.api.nvim_create_user_command("QuartoSplitClose", close, { desc = "Cierra el preview de Quarto y restaura el layout" })

-- Inserta un comentario de Quarto/markdown "<!--  -->" en la posición del
-- cursor y entra en modo inserción justo en el medio, listo para escribir.
local function insert_comment()
  local left, right = "<!-- ", " -->"
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_set_current_line(line:sub(1, col) .. left .. right .. line:sub(col + 1))
  vim.api.nvim_win_set_cursor(0, { row, col + #left })
  vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("QuartoComment", insert_comment, { desc = "Inserta <!--  --> y deja el cursor en medio" })

-- Keymap buffer-local solo en archivos quarto/markdown: <leader>ci ("comment insert").
-- Grupo propio: AUGROUP se limpia al abrir/cerrar el split y borraría el keymap.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("QuartoComment", { clear = true }),
  pattern = { "quarto", "markdown" },
  callback = function(ev)
    vim.keymap.set("n", "<leader>ci", insert_comment, {
      buffer = ev.buf,
      desc = "Insertar comentario Quarto (cursor en medio)",
    })
  end,
})
