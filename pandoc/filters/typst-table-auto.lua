-- Reset every table's column widths to "default" so the Typst writer emits
-- auto-sized columns (`columns: N`) instead of rigid percentages like
-- (25%,25%,25%,25%). Auto columns size to content and wrap long text, which
-- is far more readable for mixed prose/code tables.
function Table(t)
  if t.colspecs then
    for i, cs in ipairs(t.colspecs) do
      t.colspecs[i] = { cs[1], nil }  -- keep alignment, drop the width
    end
  end
  return t
end
