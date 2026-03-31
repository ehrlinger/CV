-- bold-author.lua
-- Bolds "Ehrlinger" in bibliography divs (refs, refs-peer, refs-submitted, etc.)
-- Matches "Ehrlinger" with or without trailing punctuation (comma, period, etc.)

local function bold_name(el)
  -- Match "Ehrlinger" optionally followed by punctuation like "," or "."
  local before, punct = el.text:match("^(Ehrlinger)([%p]*)$")
  if before then
    local result = { pandoc.Strong({ pandoc.Str(before) }) }
    if punct ~= "" then
      result[#result + 1] = pandoc.Str(punct)
    end
    return pandoc.Span(result)
  end
end

function Div(div)
  if div.identifier and div.identifier:match("^refs") then
    return div:walk({ Str = bold_name })
  end
end
