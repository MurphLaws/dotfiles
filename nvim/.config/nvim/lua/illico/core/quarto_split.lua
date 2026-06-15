-- Quarto split preview, estilo markdown-preview:
--   :QuartoSplit       arranca `quarto preview` del archivo actual y abre el
--                      render en un VISOR WebKit nativo (qpreview, NO un
--                      navegador) que se coloca solo en la mitad derecha;
--                      Ghostty se tilea a la izquierda marcando el tmux window
--                      con @quarto_tile.
--   :QuartoSplitClose  detiene el preview, cierra el visor y restaura el layout.
--
-- Al guardar (:w) quarto re-renderiza y el visor se recarga solo vía el
-- livereload (websocket) que quarto inyecta en el HTML.
--
-- Requisitos: `quarto` y `swiftc` en PATH (swiftc viene con las Command Line
-- Tools). El visor se compila una sola vez a ~/.cache/quarto-preview/qpreview.
-- El tiling de Ghostty lo hace ~/.tmux/scripts/quarto-tile.sh (vía System
-- Events => requiere permiso de Accesibilidad para Ghostty una sola vez).

local PORT = 7777
local URL = "http://127.0.0.1:" .. PORT
local SRC = vim.fn.expand("~/.tmux/scripts/qpreview.swift")
local BIN = vim.fn.expand("~/.cache/quarto-preview/qpreview")
local TILE = vim.fn.expand("~/.tmux/scripts/quarto-tile.sh")

local state = { job = nil, viewer = nil, file = nil }

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

-- Compila el visor WebKit si falta o si el fuente es más nuevo que el binario.
local function ensure_viewer()
  if vim.fn.executable("swiftc") == 0 then
    notify("no encuentro `swiftc` (instala las Command Line Tools de Xcode)", vim.log.levels.ERROR)
    return false
  end
  local fresh = vim.fn.filereadable(BIN) == 1 and vim.fn.getftime(BIN) >= vim.fn.getftime(SRC)
  if fresh then
    return true
  end
  vim.fn.mkdir(vim.fn.fnamemodify(BIN, ":h"), "p")
  notify("compilando el visor WebKit (solo esta vez) …")
  local out = vim.fn.system({ "swiftc", "-O", SRC, "-o", BIN })
  if vim.v.shell_error ~= 0 then
    notify("falló la compilación del visor:\n" .. out, vim.log.levels.ERROR)
    return false
  end
  return true
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
  if not ensure_viewer() then
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

  -- 2) Visor WebKit en la mitad derecha (se posiciona solo desde el argumento).
  state.viewer = vim.fn.jobstart({ BIN, URL, "right" }, {
    on_exit = function()
      state.viewer = nil
    end,
  })
  if state.viewer <= 0 then
    notify("no pude arrancar el visor WebKit", vim.log.levels.ERROR)
    state.viewer = nil
    return
  end

  -- 3) Tilar Ghostty a la izquierda vía tmux.
  if in_tmux() then
    vim.fn.system({ "tmux", "set-option", "-g", "@quarto_active", "1" })
    vim.fn.system({ "tmux", "set-option", "-w", "@quarto_tile", "1" })
    vim.fn.system({ "bash", TILE })
    notify("split listo (Ghostty izq. / visor der.)")
  else
    notify("preview abierto; sin tmux no hay tiling automático de Ghostty")
  end
end

local function close(opts)
  if state.job then
    vim.fn.jobstop(state.job)
    state.job = nil
  end
  -- Cerrar el visor (al matar el proceso, su NSWindow se cierra y el proceso sale).
  if state.viewer then
    vim.fn.jobstop(state.viewer)
    state.viewer = nil
  end

  if in_tmux() then
    vim.fn.system({ "tmux", "set-option", "-wu", "@quarto_tile" })
    -- restaurar Ghostty a pantalla completa
    vim.fn.system({ "tmux", "set-option", "-g", "@quarto_active", "1" })
    vim.fn.system({ "bash", TILE })
    vim.fn.system({ "tmux", "set-option", "-gu", "@quarto_active" })
  end
  state.file = nil
  notify("preview cerrado y layout restaurado")
end

vim.api.nvim_create_user_command("QuartoSplit", open, { desc = "Quarto preview en split (nvim izq / visor WebKit der)" })
vim.api.nvim_create_user_command("QuartoSplitClose", close, { desc = "Cierra el preview de Quarto y restaura el layout" })
