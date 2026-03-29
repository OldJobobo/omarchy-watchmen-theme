local palette = {
  bg = "#2C2D37",
  bg_alt = "#55595D",
  bg_highlight = "#846B75",
  bg_visual = "#555F72",
  bg_status = "#55595D",
  bg_float = "#2C2D37",
  bg_popup = "#2C2D37",
  fg = "#CEB8B0",
  fg_bright = "#DFC0B0",
  fg_muted = "#B1A0AA",
  fg_subtle = "#AEA8A9",
  comment = "#726764",
  comment_alt = "#846B75",
  border = "#55595D",
  border_bright = "#6E7B8C",
  accent = "#9287B0",
  accent_alt = "#AD93B7",
  red = "#C13E46",
  red_dim = "#7B2B4C",
  rose = "#D8979A",
  green = "#ADC4B3",
  green_dim = "#4F7549",
  olive = "#A7A793",
  yellow = "#D2833B",
  blue = "#6E7B8C",
  blue_alt = "#8EB3C0",
  magenta = "#AD93B7",
  purple = "#B1A9C2",
  cyan = "#80BCC0",
  cyan_dim = "#3E6274",
  orange = "#A86A3E",
  tan = "#81544E",
  paper = "#D8AAAD",
}

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "watchmen"
vim.o.background = "dark"
vim.o.termguicolors = true

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local function link(from, to)
  hi(from, { link = to })
end

hi("Normal", { fg = palette.fg, bg = palette.bg })
hi("NormalNC", { fg = palette.fg, bg = palette.bg })
hi("NormalFloat", { fg = palette.fg, bg = palette.bg_float })
hi("FloatBorder", { fg = palette.border, bg = palette.bg_float })
hi("FloatTitle", { fg = palette.accent, bg = palette.bg_float, bold = true })
hi("ColorColumn", { bg = palette.bg_alt })
hi("Conceal", { fg = palette.comment_alt })
hi("CurSearch", { fg = palette.bg, bg = palette.orange, bold = true })
hi("Cursor", { fg = palette.bg, bg = palette.fg_bright })
hi("lCursor", { fg = palette.bg, bg = palette.fg_bright })
hi("CursorIM", { fg = palette.bg, bg = palette.fg_bright })
hi("CursorColumn", { bg = palette.bg_alt })
hi("CursorLine", { bg = palette.bg_alt })
hi("CursorLineNr", { fg = palette.accent, bg = palette.bg_alt, bold = true })
hi("Directory", { fg = palette.accent })
hi("EndOfBuffer", { fg = palette.bg })
hi("ErrorMsg", { fg = palette.red, bg = palette.bg })
hi("WinSeparator", { fg = palette.border_bright })
hi("Folded", { fg = palette.comment, bg = palette.bg_alt })
hi("FoldColumn", { fg = palette.comment, bg = palette.bg })
hi("SignColumn", { fg = palette.comment, bg = palette.bg })
hi("IncSearch", { fg = palette.bg, bg = palette.yellow, bold = true })
hi("Substitute", { fg = palette.bg, bg = palette.magenta, bold = true })
hi("LineNr", { fg = palette.comment, bg = palette.bg })
hi("MatchParen", { fg = palette.fg_bright, bg = palette.bg_visual, bold = true })
hi("ModeMsg", { fg = palette.green, bold = true })
hi("MoreMsg", { fg = palette.green })
hi("NonText", { fg = palette.border })
hi("Pmenu", { fg = palette.fg, bg = palette.bg_popup })
hi("PmenuSel", { fg = palette.fg_bright, bg = palette.bg_visual, bold = true })
hi("PmenuSbar", { bg = palette.bg_alt })
hi("PmenuThumb", { bg = palette.border })
hi("Question", { fg = palette.accent })
hi("QuickFixLine", { bg = palette.bg_visual, bold = true })
hi("Search", { fg = palette.bg, bg = palette.accent })
hi("SpecialKey", { fg = palette.comment })
hi("SpellBad", { sp = palette.red, undercurl = true })
hi("SpellCap", { sp = palette.accent, undercurl = true })
hi("SpellLocal", { sp = palette.cyan, undercurl = true })
hi("SpellRare", { sp = palette.magenta, undercurl = true })
hi("StatusLine", { fg = palette.fg, bg = palette.bg_status })
hi("StatusLineNC", { fg = palette.comment, bg = palette.bg_status })
hi("TabLine", { fg = palette.comment, bg = palette.bg_status })
hi("TabLineFill", { fg = palette.comment, bg = palette.bg_status })
hi("TabLineSel", { fg = palette.fg_bright, bg = palette.bg_visual, bold = true })
hi("Title", { fg = palette.accent, bold = true })
hi("Visual", { bg = palette.bg_visual })
hi("VisualNOS", { bg = palette.bg_visual })
hi("WarningMsg", { fg = palette.yellow })
hi("Whitespace", { fg = palette.border })
hi("WildMenu", { fg = palette.fg_bright, bg = palette.bg_visual, bold = true })

hi("Comment", { fg = palette.comment, italic = true })
hi("Bold", { bold = true })
hi("Constant", { fg = palette.yellow })
hi("String", { fg = palette.green })
hi("Character", { fg = palette.green_dim })
hi("Number", { fg = palette.orange })
hi("Boolean", { fg = palette.red, bold = true })
hi("Float", { fg = palette.orange })
hi("Identifier", { fg = palette.fg })
hi("Function", { fg = palette.accent })
hi("Statement", { fg = palette.red })
hi("Conditional", { fg = palette.red })
hi("Repeat", { fg = palette.red_dim })
hi("Label", { fg = palette.yellow })
hi("Operator", { fg = palette.fg_muted })
hi("Keyword", { fg = palette.red })
hi("Exception", { fg = palette.red })
hi("PreProc", { fg = palette.purple })
hi("Include", { fg = palette.accent })
hi("Define", { fg = palette.purple })
hi("Macro", { fg = palette.purple })
hi("PreCondit", { fg = palette.magenta })
hi("Type", { fg = palette.cyan })
hi("StorageClass", { fg = palette.purple })
hi("Structure", { fg = palette.blue })
hi("Typedef", { fg = palette.cyan })
hi("Special", { fg = palette.magenta })
hi("SpecialChar", { fg = palette.orange })
hi("Tag", { fg = palette.accent })
hi("Delimiter", { fg = palette.fg_muted })
hi("SpecialComment", { fg = palette.comment, italic = true })
hi("Debug", { fg = palette.orange })
hi("Underlined", { fg = palette.cyan, underline = true })
hi("Ignore", { fg = palette.comment })
hi("Italic", { italic = true })
hi("Error", { fg = palette.red, bold = true })
hi("Strikethrough", { strikethrough = true })
hi("Todo", { fg = palette.bg, bg = palette.accent, bold = true })

hi("DiagnosticDeprecated", { fg = palette.tan, strikethrough = true })
hi("DiagnosticUnnecessary", { fg = palette.comment_alt })

hi("DiagnosticError", { fg = palette.red })
hi("DiagnosticWarn", { fg = palette.yellow })
hi("DiagnosticInfo", { fg = palette.cyan })
hi("DiagnosticHint", { fg = palette.green })
hi("DiagnosticOk", { fg = palette.green })
hi("DiagnosticSignError", { fg = palette.red, bg = palette.bg })
hi("DiagnosticSignWarn", { fg = palette.yellow, bg = palette.bg })
hi("DiagnosticSignInfo", { fg = palette.cyan, bg = palette.bg })
hi("DiagnosticSignHint", { fg = palette.green, bg = palette.bg })
hi("DiagnosticVirtualTextError", { fg = palette.red, bg = palette.bg_alt, italic = true })
hi("DiagnosticVirtualTextWarn", { fg = palette.yellow, bg = palette.bg_alt, italic = true })
hi("DiagnosticVirtualTextInfo", { fg = palette.cyan, bg = palette.bg_alt, italic = true })
hi("DiagnosticVirtualTextHint", { fg = palette.green, bg = palette.bg_alt, italic = true })
hi("DiagnosticUnderlineError", { sp = palette.red, undercurl = true })
hi("DiagnosticUnderlineWarn", { sp = palette.yellow, undercurl = true })
hi("DiagnosticUnderlineInfo", { sp = palette.cyan, undercurl = true })
hi("DiagnosticUnderlineHint", { sp = palette.green, undercurl = true })

hi("DiffAdd", { fg = palette.green, bg = palette.bg_alt })
hi("DiffChange", { fg = palette.accent, bg = palette.bg_alt })
hi("DiffDelete", { fg = palette.red, bg = palette.bg_alt })
hi("DiffText", { fg = palette.fg_bright, bg = palette.bg_visual, bold = true })
hi("Added", { fg = palette.green })
hi("Changed", { fg = palette.accent })
hi("Removed", { fg = palette.red })

hi("GitSignsAdd", { fg = palette.green, bg = palette.bg })
hi("GitSignsChange", { fg = palette.accent, bg = palette.bg })
hi("GitSignsDelete", { fg = palette.red, bg = palette.bg })
hi("GitSignsTopdelete", { fg = palette.red, bg = palette.bg })
hi("GitSignsChangedelete", { fg = palette.yellow, bg = palette.bg })
hi("MiniDiffSignAdd", { fg = palette.green, bg = palette.bg })
hi("MiniDiffSignChange", { fg = palette.accent, bg = palette.bg })
hi("MiniDiffSignDelete", { fg = palette.red, bg = palette.bg })

hi("MiniIconsGrey", { fg = palette.border })
hi("MiniIconsRed", { fg = palette.red_dim })
hi("MiniIconsBlue", { fg = palette.accent })
hi("MiniIconsGreen", { fg = palette.green })
hi("MiniIconsYellow", { fg = palette.yellow })
hi("MiniIconsOrange", { fg = palette.orange })
hi("MiniIconsPurple", { fg = palette.magenta })
hi("MiniIconsAzure", { fg = palette.blue_alt })
hi("MiniIconsCyan", { fg = palette.cyan })

hi("BlinkCmpMenu", { fg = palette.fg, bg = palette.bg_popup })
hi("BlinkCmpMenuBorder", { fg = palette.border, bg = palette.bg_popup })
hi("BlinkCmpMenuSelection", { fg = palette.fg_bright, bg = palette.bg_visual, bold = true })
hi("BlinkCmpScrollBarGutter", { bg = palette.bg_alt })
hi("BlinkCmpScrollBarThumb", { bg = palette.border })
hi("BlinkCmpDoc", { fg = palette.fg, bg = palette.bg_float })
hi("BlinkCmpDocBorder", { fg = palette.border, bg = palette.bg_float })
hi("BlinkCmpDocSeparator", { fg = palette.border, bg = palette.bg_float })
hi("BlinkCmpLabel", { fg = palette.fg })
hi("BlinkCmpLabelMatch", { fg = palette.accent, bold = true })
hi("BlinkCmpLabelDetail", { fg = palette.comment })
hi("BlinkCmpLabelDescription", { fg = palette.comment })
hi("BlinkCmpSource", { fg = palette.comment_alt })
hi("BlinkCmpKind", { fg = palette.accent })

hi("CmpItemAbbr", { fg = palette.fg })
hi("CmpItemAbbrMatch", { fg = palette.accent, bold = true })
hi("CmpItemMenu", { fg = palette.comment_alt })
hi("CmpItemKind", { fg = palette.accent })

hi("NoiceCmdlinePopup", { fg = palette.fg, bg = palette.bg_float })
hi("NoiceCmdlinePopupBorder", { fg = palette.border, bg = palette.bg_float })
hi("NoiceCmdlineIcon", { fg = palette.accent })

hi("IblIndent", { fg = palette.border, nocombine = true })
hi("IblWhitespace", { fg = palette.border, nocombine = true })
hi("IblScope", { fg = palette.fg_muted, nocombine = true })
hi("IndentBlanklineChar", { fg = palette.border, nocombine = true })
hi("IndentBlanklineContextChar", { fg = palette.fg_muted, nocombine = true })

hi("LspReferenceText", { bg = palette.bg_alt })
hi("LspReferenceRead", { bg = palette.bg_alt })
hi("LspReferenceWrite", { bg = palette.bg_highlight })
hi("LspCodeLens", { fg = palette.comment })
hi("LspCodeLensSeparator", { fg = palette.border })
hi("LspInlayHint", { fg = palette.comment, bg = palette.bg_alt })

hi("TelescopeNormal", { fg = palette.fg, bg = palette.bg_float })
hi("TelescopeBorder", { fg = palette.border, bg = palette.bg_float })
hi("TelescopeTitle", { fg = palette.accent, bg = palette.bg_float, bold = true })
hi("TelescopePromptNormal", { fg = palette.fg, bg = palette.bg_popup })
hi("TelescopePromptBorder", { fg = palette.border, bg = palette.bg_popup })
hi("TelescopePromptTitle", { fg = palette.bg, bg = palette.accent, bold = true })
hi("TelescopeResultsNormal", { fg = palette.fg, bg = palette.bg_float })
hi("TelescopeResultsBorder", { fg = palette.border, bg = palette.bg_float })
hi("TelescopePreviewNormal", { fg = palette.fg, bg = palette.bg_float })
hi("TelescopePreviewBorder", { fg = palette.border, bg = palette.bg_float })
hi("TelescopeSelection", { fg = palette.fg_bright, bg = palette.bg_visual, bold = true })
hi("TelescopeMatching", { fg = palette.yellow, bold = true })

hi("WhichKey", { fg = palette.accent })
hi("WhichKeyGroup", { fg = palette.purple })
hi("WhichKeyDesc", { fg = palette.cyan })
hi("WhichKeySeparator", { fg = palette.border })
hi("WhichKeyValue", { fg = palette.comment_alt })

hi("NeoTreeNormal", { fg = palette.fg, bg = palette.bg })
hi("NeoTreeNormalNC", { fg = palette.fg, bg = palette.bg })
hi("NeoTreeDirectoryName", { fg = palette.accent })
hi("NeoTreeDirectoryIcon", { fg = palette.blue_alt })
hi("NeoTreeRootName", { fg = palette.yellow, bold = true })
hi("NeoTreeGitAdded", { fg = palette.green })
hi("NeoTreeGitModified", { fg = palette.orange })
hi("NeoTreeGitDeleted", { fg = palette.red })
hi("NeoTreeIndentMarker", { fg = palette.border })
hi("NeoTreeFloatBorder", { fg = palette.border, bg = palette.bg_float })
hi("NeoTreeTitleBar", { fg = palette.bg, bg = palette.accent, bold = true })

hi("RenderMarkdownH1", { fg = palette.accent_alt, bold = true })
hi("RenderMarkdownH2", { fg = palette.accent, bold = true })
hi("RenderMarkdownH3", { fg = palette.cyan, bold = true })
hi("RenderMarkdownH4", { fg = palette.purple, bold = true })
hi("RenderMarkdownH5", { fg = palette.yellow, bold = true })
hi("RenderMarkdownH6", { fg = palette.orange, bold = true })
hi("RenderMarkdownCode", { bg = palette.bg_alt })
hi("RenderMarkdownBullet", { fg = palette.rose })
hi("RenderMarkdownQuote", { fg = palette.comment_alt })
hi("RenderMarkdownLink", { fg = palette.accent, underline = true })
hi("RenderMarkdownChecked", { fg = palette.green })
hi("RenderMarkdownUnchecked", { fg = palette.comment_alt })

link("@annotation", "PreProc")
link("@attribute", "PreProc")
link("@boolean", "Boolean")
link("@character", "Character")
link("@character.special", "SpecialChar")
link("@comment", "Comment")
link("@conceal", "Conceal")
link("@conditional", "Conditional")
link("@constant", "Constant")
link("@constant.builtin", "Special")
link("@constant.macro", "Define")
link("@constructor", "Type")
link("@debug", "Debug")
link("@define", "Define")
link("@error", "Error")
link("@exception", "Exception")
link("@field", "Special")
link("@float", "Float")
link("@function", "Function")
link("@function.builtin", "Special")
link("@function.call", "Function")
link("@function.macro", "Macro")
link("@include", "Include")
link("@keyword", "Keyword")
link("@keyword.function", "Keyword")
link("@keyword.operator", "Operator")
link("@keyword.return", "Keyword")
link("@label", "Label")
link("@method", "Function")
link("@method.call", "Function")
link("@module", "Structure")
link("@namespace", "Structure")
link("@none", "Normal")
link("@number", "Number")
link("@operator", "Operator")
link("@parameter", "Identifier")
link("@parameter.reference", "Identifier")
link("@property", "Special")
link("@punctuation.bracket", "Delimiter")
link("@punctuation.delimiter", "Delimiter")
link("@punctuation.special", "Special")
link("@repeat", "Repeat")
link("@storageclass", "StorageClass")
link("@string", "String")
link("@string.escape", "SpecialChar")
link("@string.regex", "Special")
link("@string.special", "Special")
link("@symbol", "Constant")
link("@tag", "Tag")
link("@tag.attribute", "Special")
link("@tag.delimiter", "Delimiter")
link("@text", "Normal")
link("@text.danger", "DiagnosticError")
link("@text.diff.add", "DiffAdd")
link("@text.diff.delete", "DiffDelete")
link("@text.emphasis", "Italic")
link("@text.environment", "Macro")
link("@text.environment.name", "Type")
link("@text.literal", "String")
link("@text.math", "Special")
link("@text.note", "DiagnosticInfo")
link("@text.reference", "Underlined")
link("@text.strike", "Strikethrough")
link("@text.strong", "Bold")
link("@text.title", "Title")
link("@text.todo", "Todo")
link("@text.underline", "Underlined")
link("@text.uri", "Underlined")
link("@text.warning", "DiagnosticWarn")
link("@type", "Type")
link("@type.builtin", "Type")
link("@type.definition", "Typedef")
link("@type.qualifier", "StorageClass")
link("@variable", "Identifier")
link("@variable.builtin", "Keyword")
link("@markup.heading", "Title")
link("@markup.heading.1", "RenderMarkdownH1")
link("@markup.heading.2", "RenderMarkdownH2")
link("@markup.heading.3", "RenderMarkdownH3")
link("@markup.heading.4", "RenderMarkdownH4")
link("@markup.heading.5", "RenderMarkdownH5")
link("@markup.heading.6", "RenderMarkdownH6")
link("@markup.link", "Underlined")
link("@markup.link.label", "Identifier")
link("@markup.link.url", "Underlined")
link("@markup.list", "RenderMarkdownBullet")
link("@markup.quote", "RenderMarkdownQuote")
link("@markup.raw", "String")
link("@markup.strong", "Bold")
link("@markup.italic", "Italic")
link("@markup.strikethrough", "Strikethrough")
link("@lsp.type.property", "@property")
link("@lsp.type.variable", "@variable")
link("@lsp.type.parameter", "@parameter")
link("@lsp.type.namespace", "@namespace")
link("@lsp.type.type", "@type")
link("@lsp.type.class", "@type")
link("@lsp.type.enum", "@type")
link("@lsp.type.interface", "@type")
link("@lsp.type.function", "@function")
link("@lsp.type.method", "@method")
link("@lsp.type.macro", "@function.macro")
link("@lsp.mod.readonly", "Constant")
link("@lsp.mod.defaultLibrary", "Type")

for _, kind in ipairs({
  "Text",
  "Method",
  "Function",
  "Constructor",
  "Field",
  "Variable",
  "Class",
  "Interface",
  "Module",
  "Property",
  "Unit",
  "Value",
  "Enum",
  "Keyword",
  "Snippet",
  "Color",
  "File",
  "Reference",
  "Folder",
  "EnumMember",
  "Constant",
  "Struct",
  "Event",
  "Operator",
  "TypeParameter",
}) do
  hi("BlinkCmpKind" .. kind, { fg = palette.accent })
  hi("CmpItemKind" .. kind, { fg = palette.accent })
end

hi("BlinkCmpKindClass", { fg = palette.cyan })
hi("BlinkCmpKindColor", { fg = palette.yellow })
hi("BlinkCmpKindConstant", { fg = palette.yellow })
hi("BlinkCmpKindEnum", { fg = palette.purple })
hi("BlinkCmpKindEvent", { fg = palette.red_dim })
hi("BlinkCmpKindField", { fg = palette.magenta })
hi("BlinkCmpKindFile", { fg = palette.fg_subtle })
hi("BlinkCmpKindFolder", { fg = palette.blue_alt })
hi("BlinkCmpKindFunction", { fg = palette.accent })
hi("BlinkCmpKindInterface", { fg = palette.cyan_dim })
hi("BlinkCmpKindKeyword", { fg = palette.red })
hi("BlinkCmpKindMethod", { fg = palette.accent_alt })
hi("BlinkCmpKindModule", { fg = palette.blue })
hi("BlinkCmpKindOperator", { fg = palette.fg_muted })
hi("BlinkCmpKindProperty", { fg = palette.magenta })
hi("BlinkCmpKindReference", { fg = palette.comment_alt })
hi("BlinkCmpKindSnippet", { fg = palette.purple })
hi("BlinkCmpKindStruct", { fg = palette.cyan })
hi("BlinkCmpKindText", { fg = palette.fg })
hi("BlinkCmpKindTypeParameter", { fg = palette.purple })
hi("BlinkCmpKindUnit", { fg = palette.green_dim })
hi("BlinkCmpKindValue", { fg = palette.yellow })
hi("BlinkCmpKindVariable", { fg = palette.fg_muted })

hi("CmpItemKindClass", { fg = palette.cyan })
hi("CmpItemKindColor", { fg = palette.yellow })
hi("CmpItemKindConstant", { fg = palette.yellow })
hi("CmpItemKindEnum", { fg = palette.purple })
hi("CmpItemKindEvent", { fg = palette.red_dim })
hi("CmpItemKindField", { fg = palette.magenta })
hi("CmpItemKindFile", { fg = palette.fg_subtle })
hi("CmpItemKindFolder", { fg = palette.blue_alt })
hi("CmpItemKindFunction", { fg = palette.accent })
hi("CmpItemKindInterface", { fg = palette.cyan_dim })
hi("CmpItemKindKeyword", { fg = palette.red })
hi("CmpItemKindMethod", { fg = palette.accent_alt })
hi("CmpItemKindModule", { fg = palette.blue })
hi("CmpItemKindOperator", { fg = palette.fg_muted })
hi("CmpItemKindProperty", { fg = palette.magenta })
hi("CmpItemKindReference", { fg = palette.comment_alt })
hi("CmpItemKindSnippet", { fg = palette.purple })
hi("CmpItemKindStruct", { fg = palette.cyan })
hi("CmpItemKindText", { fg = palette.fg })
hi("CmpItemKindTypeParameter", { fg = palette.purple })
hi("CmpItemKindUnit", { fg = palette.green_dim })
hi("CmpItemKindValue", { fg = palette.yellow })
hi("CmpItemKindVariable", { fg = palette.fg_muted })
