# Custom shell functions

# Copy file to clipboard for pasting into apps
cpfile() {
  local file="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
  osascript -e "set the clipboard to POSIX file \"$file\""
  echo "Copied: $file"
}

# Copy file's text content to clipboard
cptext() {
  cat "$1" | pbcopy
  echo "Copied contents of: $1"
}

# Convert markdown to PDF (direct via pandoc)
md2pdf() {
  local input="$1"
  local output="${2:-${input%.md}.pdf}"
  pandoc "$input" -o "$output" \
    -V geometry:margin=0.75in \
    -V fontsize=11pt && echo "Created: $output"
}

# Convert markdown to HTML (styled)
md2html() {
  local input="$1"
  local output="${2:-${input%.md}.html}"
  pandoc "$input" -o "$output" \
    --standalone \
    --metadata title="$(basename "${input%.md}")" \
    -H <(cat << 'STYLE'
<style>
body { font-family: -apple-system, sans-serif; font-size: 12pt; max-width: 800px; margin: 40px auto; padding: 0 20px; line-height: 1.6; }
pre, code { white-space: pre-wrap; word-wrap: break-word; background: #f5f5f5; padding: 16px; border-radius: 4px; line-height: 1.5; display: block; }
pre code { padding: 0; }
table { border-collapse: collapse; width: 100%; margin: 1em 0; }
td, th { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background: #f5f5f5; }
h1, h2, h3 { color: #333; }
h2 { border-bottom: 1px solid #eee; padding-bottom: 8px; }
</style>
STYLE
) && echo "Created: $output"
}

# Convert HTML to PDF (via Chrome headless)
html2pdf() {
  local input="$1"
  local output="${2:-${input%.html}.pdf}"
  local filepath="$(cd "$(dirname "$input")" && pwd)/$(basename "$input")"
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    --headless=new \
    --disable-gpu \
    --no-pdf-header-footer \
    --print-to-pdf="$output" \
    "file://$filepath" 2>/dev/null && echo "Created: $output"
}

# Extract text from PDF
pdf2text() {
  local input="$1"
  local output="${2:-${input%.pdf}.txt}"
  pdftotext "$input" "$output" && echo "Created: $output"
}
