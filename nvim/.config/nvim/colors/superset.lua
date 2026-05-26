-- Superset — warm coral/sage/amber palette inspired by Claude Code Superset
-- Transparency-friendly: bg slots use "NONE" so ghostty/tmux blur shows through.

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end

vim.g.colors_name = "superset"
vim.o.background = "dark"
vim.o.termguicolors = true

local p = {
  -- backgrounds (mostly transparent in practice; used for non-transparent panes)
  bg        = "#0d0d0d",
  bg_alt    = "#151515",
  bg_float  = "#1c1c1c",
  bg_sel    = "#2a2a28",
  bg_hl     = "#1f1e1c",

  -- foregrounds
  fg        = "#e8e3d8",
  fg_muted  = "#a8a39a",
  fg_dim    = "#6e6863",
  fg_ghost  = "#3d3a36",

  -- accents
  coral     = "#ff8c5a",
  peach     = "#ffa775",
  coral_dim = "#cc6e44",
  green     = "#7ec77e",
  green_dim = "#5fa05f",
  amber     = "#f0c674",
  gold      = "#d4a849",
  sky       = "#8ec9d6",
  blue      = "#6ba8c4",
  mauve     = "#b89cd9",
  purple    = "#9a7fc2",
  red       = "#e07070",
  crimson   = "#c45656",

  -- diff
  diff_add    = "#1f2e1f",
  diff_change = "#2a261a",
  diff_delete = "#2e1a1a",
  diff_text   = "#2a3a2a",
}

local hl = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end

-- core ui
hl("Normal",           { fg = p.fg, bg = "NONE" })
hl("NormalNC",         { fg = p.fg, bg = "NONE" })
hl("NormalFloat",      { fg = p.fg, bg = "NONE" })
hl("FloatBorder",      { fg = p.fg_dim, bg = "NONE" })
hl("FloatTitle",       { fg = p.coral, bg = "NONE", bold = true })
hl("WinSeparator",     { fg = p.fg_ghost, bg = "NONE" })
hl("VertSplit",        { fg = p.fg_ghost, bg = "NONE" })
hl("EndOfBuffer",      { fg = p.fg_ghost, bg = "NONE" })
hl("LineNr",           { fg = p.fg_dim })
hl("CursorLineNr",     { fg = p.coral, bold = true })
hl("CursorLine",       { bg = p.bg_hl })
hl("CursorColumn",     { bg = p.bg_hl })
hl("ColorColumn",      { bg = p.bg_alt })
hl("SignColumn",       { bg = "NONE" })
hl("Folded",           { fg = p.fg_dim, bg = p.bg_alt, italic = true })
hl("FoldColumn",       { fg = p.fg_dim, bg = "NONE" })

-- cursor & selection
hl("Cursor",           { fg = p.bg, bg = p.coral })
hl("lCursor",          { fg = p.bg, bg = p.coral })
hl("TermCursor",       { fg = p.bg, bg = p.coral })
hl("Visual",           { bg = p.bg_sel })
hl("VisualNOS",        { bg = p.bg_sel })
hl("MatchParen",       { fg = p.coral, bold = true, underline = true })

-- search
hl("Search",           { fg = p.bg, bg = p.amber, bold = true })
hl("IncSearch",        { fg = p.bg, bg = p.coral, bold = true })
hl("CurSearch",        { fg = p.bg, bg = p.peach, bold = true })
hl("Substitute",       { fg = p.bg, bg = p.coral })

-- statusline / tabline
hl("StatusLine",       { fg = p.fg_muted, bg = "NONE" })
hl("StatusLineNC",     { fg = p.fg_dim,   bg = "NONE" })
hl("TabLine",          { fg = p.fg_dim,   bg = "NONE" })
hl("TabLineSel",       { fg = p.coral,    bg = "NONE", bold = true })
hl("TabLineFill",      { bg = "NONE" })
hl("WinBar",           { fg = p.fg_muted, bg = "NONE" })
hl("WinBarNC",         { fg = p.fg_dim,   bg = "NONE" })

-- pum (completion popup)
hl("Pmenu",            { fg = p.fg, bg = p.bg_float })
hl("PmenuSel",         { fg = p.bg, bg = p.coral, bold = true })
hl("PmenuSbar",        { bg = p.bg_alt })
hl("PmenuThumb",       { bg = p.fg_dim })
hl("PmenuKind",        { fg = p.mauve, bg = p.bg_float })
hl("PmenuKindSel",     { fg = p.bg, bg = p.coral, bold = true })
hl("PmenuExtra",       { fg = p.fg_dim, bg = p.bg_float })
hl("PmenuExtraSel",    { fg = p.bg, bg = p.coral })

-- messages
hl("ModeMsg",          { fg = p.coral, bold = true })
hl("MoreMsg",          { fg = p.green })
hl("ErrorMsg",         { fg = p.red, bold = true })
hl("WarningMsg",       { fg = p.amber })
hl("Question",         { fg = p.sky })
hl("Directory",        { fg = p.coral, bold = true })
hl("Title",            { fg = p.coral, bold = true })
hl("Conceal",          { fg = p.fg_dim })
hl("NonText",          { fg = p.fg_ghost })
hl("SpecialKey",       { fg = p.fg_ghost })
hl("Whitespace",       { fg = p.fg_ghost })

-- spell
hl("SpellBad",         { sp = p.red,   undercurl = true })
hl("SpellCap",         { sp = p.amber, undercurl = true })
hl("SpellLocal",       { sp = p.sky,   undercurl = true })
hl("SpellRare",        { sp = p.mauve, undercurl = true })

-- syntax (legacy)
hl("Comment",          { fg = p.fg_dim, italic = true })
hl("Constant",         { fg = p.peach })
hl("String",           { fg = p.green })
hl("Character",        { fg = p.green })
hl("Number",           { fg = p.peach })
hl("Boolean",          { fg = p.peach, bold = true })
hl("Float",            { fg = p.peach })
hl("Identifier",       { fg = p.fg })
hl("Function",         { fg = p.amber, bold = true })
hl("Statement",        { fg = p.coral })
hl("Conditional",      { fg = p.coral })
hl("Repeat",           { fg = p.coral })
hl("Label",            { fg = p.coral })
hl("Operator",         { fg = p.fg_muted })
hl("Keyword",          { fg = p.coral, bold = true })
hl("Exception",        { fg = p.red, bold = true })
hl("PreProc",          { fg = p.mauve })
hl("Include",          { fg = p.mauve })
hl("Define",           { fg = p.mauve })
hl("Macro",            { fg = p.mauve })
hl("PreCondit",        { fg = p.mauve })
hl("Type",             { fg = p.sky })
hl("StorageClass",     { fg = p.coral })
hl("Structure",        { fg = p.sky })
hl("Typedef",          { fg = p.sky })
hl("Special",          { fg = p.coral })
hl("SpecialChar",      { fg = p.peach })
hl("Tag",              { fg = p.coral })
hl("Delimiter",        { fg = p.fg_muted })
hl("SpecialComment",   { fg = p.amber, italic = true })
hl("Debug",            { fg = p.red })
hl("Underlined",       { fg = p.sky, underline = true })
hl("Ignore",           { fg = p.fg_dim })
hl("Error",            { fg = p.red, bold = true })
hl("Todo",             { fg = p.amber, bg = "NONE", bold = true })

-- treesitter
hl("@variable",            { fg = p.fg })
hl("@variable.builtin",    { fg = p.peach, italic = true })
hl("@variable.parameter",  { fg = p.fg, italic = true })
hl("@variable.member",     { fg = p.sky })
hl("@constant",            { fg = p.peach })
hl("@constant.builtin",    { fg = p.peach, italic = true })
hl("@constant.macro",      { fg = p.mauve })
hl("@module",              { fg = p.sky })
hl("@label",               { fg = p.coral })
hl("@string",              { fg = p.green })
hl("@string.escape",       { fg = p.peach })
hl("@string.regexp",       { fg = p.amber })
hl("@string.special",      { fg = p.peach })
hl("@character",           { fg = p.green })
hl("@number",              { fg = p.peach })
hl("@boolean",             { fg = p.peach, bold = true })
hl("@float",               { fg = p.peach })
hl("@function",            { fg = p.amber, bold = true })
hl("@function.builtin",    { fg = p.amber, italic = true })
hl("@function.call",       { fg = p.amber })
hl("@function.macro",      { fg = p.mauve })
hl("@function.method",     { fg = p.amber, bold = true })
hl("@function.method.call",{ fg = p.amber })
hl("@constructor",         { fg = p.mauve })
hl("@operator",            { fg = p.fg_muted })
hl("@keyword",             { fg = p.coral, bold = true })
hl("@keyword.function",    { fg = p.coral, bold = true })
hl("@keyword.operator",    { fg = p.coral })
hl("@keyword.return",      { fg = p.coral, bold = true })
hl("@keyword.import",      { fg = p.mauve })
hl("@keyword.exception",   { fg = p.red, bold = true })
hl("@keyword.conditional", { fg = p.coral })
hl("@keyword.repeat",      { fg = p.coral })
hl("@type",                { fg = p.sky })
hl("@type.builtin",        { fg = p.sky, italic = true })
hl("@type.definition",     { fg = p.sky, bold = true })
hl("@attribute",           { fg = p.mauve })
hl("@property",            { fg = p.sky })
hl("@punctuation.delimiter", { fg = p.fg_muted })
hl("@punctuation.bracket",   { fg = p.fg_muted })
hl("@punctuation.special",   { fg = p.coral })
hl("@comment",             { fg = p.fg_dim, italic = true })
hl("@comment.todo",        { fg = p.amber, bold = true })
hl("@comment.error",       { fg = p.red, bold = true })
hl("@comment.warning",     { fg = p.amber, bold = true })
hl("@comment.note",        { fg = p.sky, bold = true })
hl("@tag",                 { fg = p.coral })
hl("@tag.attribute",       { fg = p.amber })
hl("@tag.delimiter",       { fg = p.fg_muted })

-- markdown / docs
hl("@markup.heading",       { fg = p.coral, bold = true })
hl("@markup.heading.1",     { fg = p.coral, bold = true })
hl("@markup.heading.2",     { fg = p.amber, bold = true })
hl("@markup.heading.3",     { fg = p.green, bold = true })
hl("@markup.heading.4",     { fg = p.sky,   bold = true })
hl("@markup.heading.5",     { fg = p.mauve, bold = true })
hl("@markup.heading.6",     { fg = p.peach, bold = true })
hl("@markup.strong",        { fg = p.amber, bold = true })
hl("@markup.italic",        { fg = p.mauve, italic = true })
hl("@markup.strikethrough", { fg = p.fg_dim, strikethrough = true })
hl("@markup.underline",     { fg = p.sky, underline = true })
hl("@markup.quote",         { fg = p.fg_muted, italic = true })
hl("@markup.math",          { fg = p.peach })
hl("@markup.link",          { fg = p.sky })
hl("@markup.link.label",    { fg = p.coral })
hl("@markup.link.url",      { fg = p.sky, underline = true })
hl("@markup.raw",           { fg = p.green })
hl("@markup.raw.block",     { fg = p.green })
hl("@markup.list",          { fg = p.coral })
hl("@markup.list.checked",  { fg = p.green, bold = true })
hl("@markup.list.unchecked",{ fg = p.fg_dim })

-- diagnostics
hl("DiagnosticError",            { fg = p.red })
hl("DiagnosticWarn",             { fg = p.amber })
hl("DiagnosticInfo",             { fg = p.sky })
hl("DiagnosticHint",             { fg = p.mauve })
hl("DiagnosticOk",               { fg = p.green })
hl("DiagnosticVirtualTextError", { fg = p.red,   italic = true })
hl("DiagnosticVirtualTextWarn",  { fg = p.amber, italic = true })
hl("DiagnosticVirtualTextInfo",  { fg = p.sky,   italic = true })
hl("DiagnosticVirtualTextHint",  { fg = p.mauve, italic = true })
hl("DiagnosticUnderlineError",   { sp = p.red,   undercurl = true })
hl("DiagnosticUnderlineWarn",    { sp = p.amber, undercurl = true })
hl("DiagnosticUnderlineInfo",    { sp = p.sky,   undercurl = true })
hl("DiagnosticUnderlineHint",    { sp = p.mauve, undercurl = true })

-- lsp
hl("LspReferenceText",      { bg = p.bg_sel })
hl("LspReferenceRead",      { bg = p.bg_sel })
hl("LspReferenceWrite",     { bg = p.bg_sel, underline = true })
hl("LspSignatureActiveParameter", { fg = p.coral, bold = true })
hl("LspInlayHint",          { fg = p.fg_ghost, italic = true })

-- diff
hl("DiffAdd",     { bg = p.diff_add })
hl("DiffChange",  { bg = p.diff_change })
hl("DiffDelete",  { fg = p.red, bg = p.diff_delete })
hl("DiffText",    { bg = p.diff_text, bold = true })
hl("Added",       { fg = p.green })
hl("Changed",     { fg = p.amber })
hl("Removed",     { fg = p.red })

-- gitsigns
hl("GitSignsAdd",        { fg = p.green })
hl("GitSignsChange",     { fg = p.amber })
hl("GitSignsDelete",     { fg = p.red })
hl("GitSignsAddNr",      { fg = p.green })
hl("GitSignsChangeNr",   { fg = p.amber })
hl("GitSignsDeleteNr",   { fg = p.red })
hl("GitSignsCurrentLineBlame", { fg = p.fg_ghost, italic = true })

-- telescope
hl("TelescopeNormal",        { fg = p.fg, bg = "NONE" })
hl("TelescopeBorder",        { fg = p.fg_dim, bg = "NONE" })
hl("TelescopePromptNormal",  { fg = p.fg, bg = "NONE" })
hl("TelescopePromptBorder",  { fg = p.coral, bg = "NONE" })
hl("TelescopePromptTitle",   { fg = p.coral, bg = "NONE", bold = true })
hl("TelescopePromptPrefix",  { fg = p.coral, bg = "NONE" })
hl("TelescopeResultsNormal", { fg = p.fg, bg = "NONE" })
hl("TelescopeResultsBorder", { fg = p.fg_dim, bg = "NONE" })
hl("TelescopeResultsTitle",  { fg = p.sky, bg = "NONE" })
hl("TelescopePreviewNormal", { fg = p.fg, bg = "NONE" })
hl("TelescopePreviewBorder", { fg = p.fg_dim, bg = "NONE" })
hl("TelescopePreviewTitle",  { fg = p.green, bg = "NONE" })
hl("TelescopeMatching",      { fg = p.coral, bold = true })
hl("TelescopeSelection",     { fg = p.coral, bg = p.bg_sel, bold = true })
hl("TelescopeSelectionCaret",{ fg = p.coral, bg = p.bg_sel })

-- which-key
hl("WhichKey",          { fg = p.coral, bold = true })
hl("WhichKeyGroup",     { fg = p.amber })
hl("WhichKeyDesc",      { fg = p.fg })
hl("WhichKeySeparator", { fg = p.fg_dim })
hl("WhichKeyFloat",     { bg = "NONE" })
hl("WhichKeyBorder",    { fg = p.fg_dim, bg = "NONE" })
hl("WhichKeyValue",     { fg = p.fg_muted })

-- snacks
hl("SnacksPicker",            { bg = "NONE" })
hl("SnacksPickerNormal",      { fg = p.fg, bg = "NONE" })
hl("SnacksPickerBorder",      { fg = p.fg_dim, bg = "NONE" })
hl("SnacksPickerTitle",       { fg = p.coral, bg = "NONE", bold = true })
hl("SnacksPickerPrompt",      { fg = p.coral, bg = "NONE" })
hl("SnacksPickerInput",       { fg = p.fg, bg = "NONE" })
hl("SnacksPickerInputBorder", { fg = p.coral, bg = "NONE" })
hl("SnacksPickerList",        { fg = p.fg, bg = "NONE" })
hl("SnacksPickerListCursorLine", { bg = p.bg_sel })
hl("SnacksDashboardHeader",   { fg = p.coral })
hl("SnacksDashboardIcon",     { fg = p.amber })
hl("SnacksDashboardDesc",     { fg = p.fg })
hl("SnacksDashboardKey",      { fg = p.sky })
hl("SnacksDashboardTitle",    { fg = p.coral, bold = true })

-- noice
hl("NoiceCmdline",          { fg = p.fg })
hl("NoiceCmdlinePopup",     { fg = p.fg, bg = "NONE" })
hl("NoiceCmdlinePopupBorder",         { fg = p.coral, bg = "NONE" })
hl("NoiceCmdlinePopupBorderCmdline",  { fg = p.coral })
hl("NoiceCmdlinePopupBorderSearch",   { fg = p.amber })
hl("NoiceCmdlinePopupBorderFilter",   { fg = p.sky })

-- trouble
hl("TroubleNormal",        { fg = p.fg, bg = "NONE" })
hl("TroubleText",          { fg = p.fg })
hl("TroubleSource",        { fg = p.fg_dim, italic = true })
hl("TroubleCount",         { fg = p.coral, bg = "NONE", bold = true })
hl("TroubleFile",          { fg = p.sky, bold = true })
hl("TroubleSignError",     { fg = p.red })
hl("TroubleSignWarning",   { fg = p.amber })
hl("TroubleSignInformation", { fg = p.sky })
hl("TroubleSignHint",      { fg = p.mauve })

-- todo-comments
hl("TodoFgTODO",  { fg = p.amber, bold = true })
hl("TodoFgFIX",   { fg = p.red, bold = true })
hl("TodoFgHACK",  { fg = p.amber })
hl("TodoFgWARN",  { fg = p.amber })
hl("TodoFgPERF",  { fg = p.mauve })
hl("TodoFgNOTE",  { fg = p.sky })
hl("TodoFgTEST",  { fg = p.green })
hl("TodoBgTODO",  { fg = p.bg, bg = p.amber, bold = true })
hl("TodoBgFIX",   { fg = p.bg, bg = p.red, bold = true })
hl("TodoBgHACK",  { fg = p.bg, bg = p.amber })
hl("TodoBgWARN",  { fg = p.bg, bg = p.amber })
hl("TodoBgPERF",  { fg = p.bg, bg = p.mauve })
hl("TodoBgNOTE",  { fg = p.bg, bg = p.sky })
hl("TodoBgTEST",  { fg = p.bg, bg = p.green })

-- indent-blankline
hl("IblIndent",  { fg = p.fg_ghost })
hl("IblWhitespace", { fg = p.fg_ghost })
hl("IblScope",   { fg = p.coral })

-- mini.* generic
hl("MiniIconsAzure",  { fg = p.sky })
hl("MiniIconsBlue",   { fg = p.blue })
hl("MiniIconsCyan",   { fg = p.sky })
hl("MiniIconsGreen",  { fg = p.green })
hl("MiniIconsGrey",   { fg = p.fg_muted })
hl("MiniIconsOrange", { fg = p.coral })
hl("MiniIconsPurple", { fg = p.mauve })
hl("MiniIconsRed",    { fg = p.red })
hl("MiniIconsYellow", { fg = p.amber })

-- terminal ansi
vim.g.terminal_color_0  = p.bg
vim.g.terminal_color_1  = p.red
vim.g.terminal_color_2  = p.green
vim.g.terminal_color_3  = p.amber
vim.g.terminal_color_4  = p.sky
vim.g.terminal_color_5  = p.mauve
vim.g.terminal_color_6  = p.peach
vim.g.terminal_color_7  = p.fg
vim.g.terminal_color_8  = p.fg_dim
vim.g.terminal_color_9  = p.coral
vim.g.terminal_color_10 = p.green
vim.g.terminal_color_11 = p.gold
vim.g.terminal_color_12 = p.blue
vim.g.terminal_color_13 = p.purple
vim.g.terminal_color_14 = p.peach
vim.g.terminal_color_15 = p.fg

-- expose palette globally for other plugins (lualine, etc)
_G.superset_palette = p
