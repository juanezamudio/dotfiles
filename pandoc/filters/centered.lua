-- Centers content wrapped in a ::: centered ::: fenced div.
-- LaTeX: emits a \begin{center} block; H1/H2 inside become sized Plain blocks
--        with their inlines preserved (pandoc handles LaTeX escaping of &, %, etc.).
-- DOCX:  maps H1 -> "Title" paragraph style, H2 -> "Subtitle" (both center-aligned
--        in the default reference doc).
-- HTML:  applies inline style="text-align: center" to the div.

local function sized_para(child)
  local sizecmd
  if child.level == 1 then
    sizecmd = "{\\Huge\\bfseries "
  elseif child.level == 2 then
    sizecmd = "{\\Large "
  else
    sizecmd = "{\\large "
  end
  local inlines = { pandoc.RawInline("latex", sizecmd) }
  for _, inline in ipairs(child.content) do
    table.insert(inlines, inline)
  end
  table.insert(inlines, pandoc.RawInline("latex", "}"))
  return pandoc.Plain(inlines)
end

function Div(elem)
  if not elem.classes:includes("centered") then return nil end

  if FORMAT:match("latex") then
    local result = { pandoc.RawBlock("latex", "\\begin{center}") }
    for _, child in ipairs(elem.content) do
      if child.t == "Header" then
        table.insert(result, sized_para(child))
        table.insert(result, pandoc.RawBlock("latex", "\\par\\vspace{6pt}"))
      else
        table.insert(result, child)
      end
    end
    table.insert(result, pandoc.RawBlock("latex", "\\end{center}"))
    return result
  end

  if FORMAT == "docx" then
    local new = {}
    for _, child in ipairs(elem.content) do
      if child.t == "Header" then
        local style = child.level == 1 and "Title" or "Subtitle"
        table.insert(new, pandoc.Div(
          { pandoc.Para(child.content) },
          pandoc.Attr("", {}, { { "custom-style", style } })
        ))
      else
        table.insert(new, child)
      end
    end
    return new
  end

  if FORMAT == "html" or FORMAT == "html5" then
    elem.attributes["style"] = "text-align: center;"
    return elem
  end

  return nil
end
