local PORT = 7777
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

local state = { job = nil, viewer = nil, file = nil }

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
  state.viewer = vim.fn.jobstart({ BIN, URL, "right" }, {
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
  state.file = file
  state.launched = false
  state.output = {}

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
      if not state.launched and (line:find("Listening on", 1, true) or line:find("Browse at", 1, true)) then
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

local function close()
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
  notify("preview cerrado y layout restaurado")
end

vim.api.nvim_create_user_command("QuartoSplit", open, { desc = "Quarto preview en split (nvim izq / visor WebKit der)" })
vim.api.nvim_create_user_command("QuartoSplitClose", close, { desc = "Cierra el preview de Quarto y restaura el layout" })
