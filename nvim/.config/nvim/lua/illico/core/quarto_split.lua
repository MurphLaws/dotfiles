-- Quarto split preview, estilo markdown-preview:
--   :QuartoSplit       arranca `quarto preview` del archivo actual, abre el
--                      render en una ventana DEDICADA de Google Chrome (--app,
--                      sin pestañas) y tilea Ghostty (izq.) + Chrome (der.)
--                      marcando el tmux window con @quarto_tile.
--   :QuartoSplitClose  detiene el preview, cierra la ventana y restaura.
--
-- Al guardar (:w) quarto re-renderiza y la ventana de Chrome se recarga sola.
--
-- Requisitos: `quarto` en PATH, Google Chrome, y permisos de macOS una sola vez
-- (Accesibilidad para Ghostty + Automatización para Chrome). El tiling lo hace
-- ~/.tmux/scripts/quarto-tile.sh, disparado por este comando y por el hook tmux.

local PORT = 7777
local URL = "http://127.0.0.1:" .. PORT
local CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
local TILE = vim.fn.expand("~/.tmux/scripts/quarto-tile.sh")

local state = { job = nil, file = nil }

local function notify(msg, level)
  vim.notify("[QuartoSplit] " .. msg, level or vim.log.levels.INFO)
end

local function in_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

-- Espera (no bloqueante para el usuario, pero síncrona) a que el server responda.
local function wait_for_server(timeout_ms)
  return vim.wait(timeout_ms or 20000, function()
    local out = vim.fn.system({ "curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", URL })
    return out == "200"
  end, 250)
end

-- Devuelve el id de la ventana de Chrome cuyo tab activo apunta a nuestro URL.
local function chrome_window_id()
  local script = string.format([[
tell application "Google Chrome"
  repeat with w in windows
    try
      if (URL of active tab of w) contains "%d" then return (id of w) as string
    end try
  end repeat
end tell
return ""]], PORT)
  local id = vim.fn.system({ "osascript", "-e", script })
  return (id or ""):gsub("%s+", "")
end

local function open(opts)
  if state.job then
    notify("ya hay un preview activo (usa :QuartoSplitClose primero)", vim.log.levels.WARN)
    return
  end
  local file = vim.fn.expand("%:p")
  if file == "" then
    notify("el buffer no tiene archivo en disco", vim.log.levels.ERROR)
    return
  end
  if vim.fn.executable("quarto") == 0 then
    notify("no encuentro `quarto` en PATH", vim.log.levels.ERROR)
    return
  end
  state.file = file

  -- 1) Servidor quarto en puerto fijo, sin abrir navegador propio.
  state.job = vim.fn.jobstart(
    { "quarto", "preview", file, "--port", tostring(PORT), "--no-browser" },
    {
      on_exit = function()
        state.job = nil
      end,
    }
  )
  if state.job <= 0 then
    notify("no pude arrancar `quarto preview`", vim.log.levels.ERROR)
    state.job = nil
    return
  end

  notify("arrancando server en " .. URL .. " …")
  if not wait_for_server() then
    notify("el server no respondió a tiempo", vim.log.levels.ERROR)
    return
  end

  -- 2) Ventana DEDICADA de Chrome en modo --app (sin pestañas).
  vim.fn.jobstart({ CHROME, "--app=" .. URL, "--new-window" }, { detach = true })

  -- 3) Esperar a que aparezca la ventana y capturar su id.
  local id = ""
  vim.wait(8000, function()
    id = chrome_window_id()
    return id ~= ""
  end, 250)

  -- 4) Marcar el tmux window y tilar.
  if in_tmux() then
    vim.fn.system({ "tmux", "set-option", "-g", "@quarto_active", "1" })
    vim.fn.system({ "tmux", "set-option", "-w", "@quarto_tile", "1" })
    if id ~= "" then
      vim.fn.system({ "tmux", "set-option", "-w", "@quarto_chrome_id", id })
    end
    vim.fn.system({ "bash", TILE })
    notify("split listo (Ghostty izq. / Chrome der.)")
  else
    notify("preview abierto; sin tmux no hay tiling automático")
  end
end

local function close(opts)
  if state.job then
    vim.fn.jobstop(state.job)
    state.job = nil
  end
  -- Cerrar la ventana --app de Chrome del preview.
  local script = string.format([[
tell application "Google Chrome"
  repeat with w in windows
    try
      if (URL of active tab of w) contains "%d" then close w
    end try
  end repeat
end tell]], PORT)
  vim.fn.system({ "osascript", "-e", script })

  if in_tmux() then
    vim.fn.system({ "tmux", "set-option", "-gu", "@quarto_active" })
    vim.fn.system({ "tmux", "set-option", "-wu", "@quarto_tile" })
    vim.fn.system({ "tmux", "set-option", "-wu", "@quarto_chrome_id" })
    -- restaurar Ghostty a pantalla completa
    vim.fn.system({ "tmux", "set-option", "-g", "@quarto_active", "1" })
    vim.fn.system({ "bash", TILE })
    vim.fn.system({ "tmux", "set-option", "-gu", "@quarto_active" })
  end
  state.file = nil
  notify("preview cerrado y layout restaurado")
end

vim.api.nvim_create_user_command("QuartoSplit", open, { desc = "Quarto preview en split (nvim izq / Chrome der)" })
vim.api.nvim_create_user_command("QuartoSplitClose", close, { desc = "Cierra el preview de Quarto y restaura el layout" })
