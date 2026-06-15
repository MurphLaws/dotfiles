local PORT = 7777
local URL = "http://127.0.0.1:" .. PORT
local SRC = vim.fn.expand("~/.tmux/scripts/qpreview.swift")
local BIN = vim.fn.expand("~/.cache/quarto-preview/qpreview")
local TILE = vim.fn.expand("~/.tmux/scripts/quarto-tile.sh")

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

local function wait_for_server(timeout_ms)
  -- 60s: el primer arranque en frío (kernel Jupyter + import de matplotlib/
  -- numpy/pandas + render del documento) pasa de los 20s de antes.
  return vim.wait(timeout_ms or 60000, function()
    return vim.fn.system({ "curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", URL }) == "200"
  end, 250)
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

  state.job = vim.fn.jobstart(
    { "quarto", "preview", file, "--port", tostring(PORT), "--no-browser" },
    { on_exit = function() state.job = nil end }
  )
  if state.job <= 0 then
    state.job = nil
    return fail("no pude arrancar `quarto preview`")
  end

  notify("arrancando server en " .. URL .. " …")
  if not wait_for_server() then
    return fail("el server no respondió a tiempo")
  end

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

local function close()
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
