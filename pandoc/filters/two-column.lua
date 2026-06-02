-- Two-column layout for content wrapped in:
--   ::: two-column
--   ::: col
--   left content
--   :::
--   ::: col
--   right content
--   :::
--   :::
--
-- LaTeX: emits two top-aligned \minipage environments at 48% width each.
-- DOCX:  emits a single-row borderless 2-column pandoc.Table.
-- HTML:  emits a flexbox div with two flex:1 children.

local function get_cols(elem)
  local cols = {}
  for _, child in ipairs(elem.content) do
    if child.t == "Div" and child.classes:includes("col") then
      table.insert(cols, child)
    end
  end
  return cols
end

function Div(elem)
  if not elem.classes:includes("two-column") then return nil end
  local cols = get_cols(elem)
  if #cols ~= 2 then return nil end

  if FORMAT:match("latex") then
    local result = {}
    table.insert(result, pandoc.RawBlock("latex", "\\noindent\\begin{minipage}[t]{0.48\\textwidth}"))
    for _, c in ipairs(cols[1].content) do table.insert(result, c) end
    table.insert(result, pandoc.RawBlock("latex", "\\end{minipage}\\hfill\\begin{minipage}[t]{0.48\\textwidth}"))
    for _, c in ipairs(cols[2].content) do table.insert(result, c) end
    table.insert(result, pandoc.RawBlock("latex", "\\end{minipage}"))
    return result
  end

  if FORMAT == "docx" then
    -- Build a SimpleTable then convert to the modern Table via pandoc.utils.
    -- Empty header row -> no header rule. Reference doc controls borders.
    local simple = pandoc.SimpleTable(
      {},
      { pandoc.AlignLeft, pandoc.AlignLeft },
      { 0.48, 0.48 },
      { {}, {} },
      { { cols[1].content, cols[2].content } }
    )
    return pandoc.utils.from_simple_table(simple)
  end

  if FORMAT == "html" or FORMAT == "html5" then
    elem.attributes["style"] = "display: flex; gap: 32pt; align-items: flex-start;"
    for _, c in ipairs(cols) do
      c.attributes["style"] = "flex: 1;"
    end
    return elem
  end

  return nil
end
