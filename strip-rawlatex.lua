-- strip-rawlatex.lua
-- Removes raw LaTeX blocks and inlines when rendering to non-PDF/LaTeX formats.
-- Prevents \newpage and similar commands appearing as literal text in Markdown output.

local is_latex = FORMAT:match("latex") or FORMAT:match("pdf") or FORMAT:match("beamer")

function RawBlock(el)
  if not is_latex and (el.format == "latex" or el.format == "tex") then
    return pandoc.Null()
  end
end

function RawInline(el)
  if not is_latex and (el.format == "latex" or el.format == "tex") then
    return pandoc.Str("")
  end
end
