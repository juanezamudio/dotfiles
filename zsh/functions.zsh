# Custom shell functions

# Show all custom aliases and functions
myhelp() {
  echo "\033[1;36m═══ Custom Commands ═══\033[0m\n"

  echo "\033[1;33mAliases & Functions (~/.zsh/aliases.zsh):\033[0m"
  awk '/^#/ {desc=substr($0,3); next} /^alias / {name=$2; gsub(/=.*/,"",name); printf "  \033[32m%-12s\033[0m %s\n", name, desc; desc=""} /^[a-z0-9_]+\(\)/ {name=$1; gsub(/\(\).*/,"",name); printf "  \033[32m%-12s\033[0m %s\n", name, desc; desc=""}' ~/.zsh/aliases.zsh 2>/dev/null

  echo "\n\033[1;33mFunctions (~/.zsh/functions.zsh):\033[0m"
  awk '/^#/ {desc=substr($0,3); next} /^[a-z0-9_]+\(\)/ {name=$1; gsub(/\(\).*/,"",name); if (name != "myhelp") printf "  \033[32m%-12s\033[0m %s\n", name, desc; desc=""}' ~/.zsh/functions.zsh 2>/dev/null
}

# Quick git add, commit, push for dotfiles from anywhere
dotfiles() {
  local msg="${1:-update dotfiles}"
  git -C ~/dotfiles add -A && \
  git -C ~/dotfiles commit -m "$msg" && \
  git -C ~/dotfiles push && \
  echo "✓ Dotfiles updated: $msg"
}

# Copy file to clipboard for pasting into apps (works with Universal Clipboard)
cpfile() {
  local file="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
  osascript <<EOF
tell application "Finder"
  select (POSIX file "$file" as alias)
  activate
end tell
delay 0.3
tell application "System Events"
  keystroke "c" using command down
  delay 0.1
  keystroke "w" using command down
end tell
EOF
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
