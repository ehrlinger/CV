-- strip-sync-markers.lua
-- Removes the BEGIN:/END: comments that mark generated regions in the source.
--
-- The Software section is rendered from hvtiR's manifest between HTML comment
-- markers. Those markers belong to the source, not to the deliverable: without
-- this filter they survive into JohnEhrlinger-CV.md, which is published to
-- gh-pages as the web CV. They are invisible when rendered, but they are build
-- scaffolding and have no business in a published document.

local function is_marker(text)
  return text:match("^%s*<!%-%-%s*BEGIN:[%w_-]+%s*%-%->%s*$") ~= nil
      or text:match("^%s*<!%-%-%s*END:[%w_-]+%s*%-%->%s*$") ~= nil
end

function RawBlock(el)
  if el.format == "html" and is_marker(el.text) then
    return pandoc.Null()
  end
end

function RawInline(el)
  if el.format == "html" and is_marker(el.text) then
    return pandoc.Str("")
  end
end
