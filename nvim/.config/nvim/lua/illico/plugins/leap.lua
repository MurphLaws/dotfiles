return {
	{
		"ggandor/leap.nvim",
		url = "https://codeberg.org/andyg/leap.nvim",
		-- Reemplazado por flash.nvim (ver flash.lua). Flash es incremental: no hay
		-- límite de 2 caracteres, se sigue escribiendo hasta que la etiqueta que
		-- quieres aparece sola. Se deja el spec por si hay que volver.
		enabled = false,
		config = function()
			local leap = require("leap")

			-- Leap necesita 2 caracteres para saltar. Por defecto muestra un
			-- "preview" (fase 1) ya con la 1ª letra; lo desactivamos para que no
			-- aparezca ningún resaltado hasta escribir las DOS letras.
			leap.opts.preview = false

			-- Ignorar mayúsculas/minúsculas al buscar (así "kp" salta a "KPI").
			-- El fork nuevo de leap quitó `opts.case_sensitive`; ahora respeta
			-- las opciones de Vim durante el salto vía `opts.vim_opts`. Forzamos
			-- ignorecase y desactivamos smartcase para que ni siquiera al teclear
			-- mayúsculas se vuelva sensible.
			leap.opts.vim_opts["go.ignorecase"] = true
			leap.opts.vim_opts["go.smartcase"] = false

			-- Búsqueda bidireccional en TODA la ventana actual (adelante y atrás
			-- a la vez), no solo hacia un lado.
			local function leap_window()
				leap.leap({ target_windows = { vim.api.nvim_get_current_win() } })
			end

			-- Igual, pero abarcando todas las ventanas visibles del tab.
			local function leap_all_windows()
				leap.leap({
					target_windows = require("leap.user").get_focusable_windows(),
				})
			end

			vim.keymap.set({ "n", "x", "o" }, "s", leap_window, { desc = "Leap: buffer actual (bidireccional)" })
			vim.keymap.set({ "n", "x", "o" }, "S", leap_all_windows, { desc = "Leap: todas las ventanas" })
			vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)")

			-- Atenúa todo el texto visible mientras leap está activo, dejando
			-- resaltados solo los matches y las etiquetas de salto.
			--
			-- No usamos el `LeapBackdrop` nativo (deprecado y se auto-desarma en
			-- el primer cambio de colorscheme). En su lugar pintamos nuestro
			-- propio backdrop con extmarks sobre las líneas visibles de cada
			-- ventana, con prioridad por debajo de los beacons de leap (65535),
			-- así los matches/labels quedan siempre por encima.
			local ns = vim.api.nvim_create_namespace("leap_backdrop")
			local BACKDROP_PRIORITY = 200

			local function set_backdrop_hl()
				-- `Comment` da un gris tenue coherente con el tema.
				vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment", default = false })
			end

			-- Matches y etiquetas de salto en rosa (destacan sobre el backdrop).
			local PINK = "#ff6ac1"
			local function set_leap_hl()
				-- Match: rosa sobre el texto (sin fondo, para no tapar).
				vim.api.nvim_set_hl(0, "LeapMatch", { fg = PINK, bold = true, nocombine = true })
				-- Label: la letra de salto, invertida en rosa para máxima lectura.
				vim.api.nvim_set_hl(0, "LeapLabel", { fg = "#1e222a", bg = PINK, bold = true, nocombine = true })
			end

			local function backdrop_on()
				for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
					local cfg = vim.api.nvim_win_get_config(win)
					if cfg.relative == "" and cfg.focusable then
						local buf = vim.api.nvim_win_get_buf(win)
						local range = vim.api.nvim_win_call(win, function()
							return { vim.fn.line("w0"), vim.fn.line("w$") }
						end)
						for l = range[1], range[2] do
							pcall(vim.api.nvim_buf_set_extmark, buf, ns, l - 1, 0, {
								end_row = l,
								end_col = 0,
								hl_group = "LeapBackdrop",
								hl_eol = true,
								priority = BACKDROP_PRIORITY,
								strict = false,
							})
						end
					end
				end
			end

			local function backdrop_off()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_valid(buf) then
						pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
					end
				end
			end

			set_backdrop_hl()
			set_leap_hl()

			local grp = vim.api.nvim_create_augroup("illico_leap_backdrop", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = grp,
				callback = function()
					set_backdrop_hl()
					set_leap_hl()
				end,
			})
			vim.api.nvim_create_autocmd("User", { pattern = "LeapEnter", group = grp, callback = backdrop_on })
			vim.api.nvim_create_autocmd("User", { pattern = "LeapLeave", group = grp, callback = backdrop_off })
		end,
	},
}
