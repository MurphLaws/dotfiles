return {
	{
		-- Dummy spec to neutralize leftover Wilder config
		"gelguy/wilder.nvim",
		enabled = false,
		init = function()
			-- If some old vimscript calls this, make it a no-op
			_G._wilder_init = function() end
		end,
	},
}
