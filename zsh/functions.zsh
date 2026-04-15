# Custom shell functions

# Show all custom commands grouped by category.
# Categories are defined in source files via "# === Category Name ===" headers.
# Each command's description is the comment line directly above its definition.
myhelp() {
  echo "\033[1;36m═══ Custom Commands ═══\033[0m"
  awk '
    /^# === .+ ===$/ {
      cat = $0
      sub(/^# === /, "", cat)
      sub(/ ===$/, "", cat)
      if (!(cat in seen)) { seen[cat] = 1; order[++n] = cat }
      desc = ""
      next
    }
    /^#/ { desc = substr($0, 3); next }
    /^alias [a-zA-Z_][a-zA-Z0-9_-]*=/ {
      name = $2; sub(/=.*/, "", name)
      if (cat != "") items[cat] = items[cat] sprintf("  \033[32m%-18s\033[0m %s\n", name, desc)
      desc = ""; next
    }
    /^[a-zA-Z_][a-zA-Z0-9_-]*\(\)/ {
      name = $1; sub(/\(\).*/, "", name)
      if (cat != "" && name != "myhelp") items[cat] = items[cat] sprintf("  \033[32m%-18s\033[0m %s\n", name, desc)
      desc = ""; next
    }
    /^[[:space:]]*$/ { desc = "" }
    END {
      for (i = 1; i <= n; i++) {
        if (items[order[i]] != "") {
          printf "\n\033[1;33m%s\033[0m\n", order[i]
          printf "%s", items[order[i]]
        }
      }
    }
  ' ~/.zsh/aliases.zsh ~/.zsh/functions.zsh 2>/dev/null
}

# === Dotfiles ===

# Quick git add, commit, push for dotfiles from anywhere
dotfiles() {
  local msg="${1:-update dotfiles}"
  git -C ~/dotfiles add -A && \
  git -C ~/dotfiles commit -m "$msg" && \
  git -C ~/dotfiles push && \
  echo "✓ Dotfiles updated: $msg"
}

# === Clipboard ===

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

# === Document Tools ===

# Convert markdown to PDF (auto-detects emojis)
md2pdf() {
  local input="$1"
  local output="${2:-${input%.md}.pdf}"

  # Check if file contains emojis
  if grep -qP '[\x{1F300}-\x{1F9FF}\x{2600}-\x{26FF}\x{2700}-\x{27BF}]' "$input" 2>/dev/null || \
     grep -q '[🚨📁📊🎯⚠️✅❌🔄📦🔐🔍📋💾📌⏳]' "$input"; then
    # File has emojis - use HTML→PDF path (Chrome handles emojis)
    echo "Emojis detected - using HTML→PDF conversion..."
    local temphtml="${input%.md}.temp.html"
    md2html "$input" "$temphtml" && \
    html2pdf "$temphtml" "$output" && \
    rm -f "$temphtml"
  else
    # No emojis - use LaTeX path (better typography)
    pandoc "$input" -o "$output" \
      -V geometry:margin=0.75in \
      -V fontsize=11pt && echo "Created: $output"
  fi
}

# Convert markdown to Word doc (for Google Docs import)
md2docx() {
  local input="$1"
  local output="${2:-${input%.md}.docx}"
  pandoc "$input" -o "$output" && echo "Created: $output"
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

# === Cloud ===

# Upload files to Google Drive via rclone (e.g., gdupload vertexcollective docs "*.pdf")
gdupload() {
  local remote="$1"
  local dest="$2"
  local pattern="${3:-*}"

  if [[ -z "$remote" || -z "$dest" ]]; then
    echo "Usage: gdupload <remote> <dest-folder> [pattern]"
    echo "Example: gdupload vertexcollective documents \"*.docx\""
    return 1
  fi

  rclone copy "$(pwd)" "$remote:/$dest" --include "$pattern" && echo "Uploaded to $remote:/$dest (pattern: $pattern)"
}

# === Claude ===

# Browse, preview, resume, or bulk-delete Claude sessions in the current project
cc-sessions() {
  local proj_dir=~/.claude/projects/$(pwd | sed 's|/|-|g; s|\.|-|g')
  if ! ls "$proj_dir"/*.jsonl >/dev/null 2>&1; then
    echo "No Claude sessions found for $PWD"
    return 1
  fi

  # Generates "<path>\t<first user prompt>" for each session, newest first.
  # Used for both initial fzf list and reload after deletions.
  local list_cmd='for f in $(ls -t '"$proj_dir"'/*.jsonl 2>/dev/null); do first=$(jq -r '"'"'select(.type=="user" and (.isMeta // false | not)) | .message.content'"'"' "$f" 2>/dev/null | grep -v "^<" | head -1 | cut -c1-80); printf "%s\t%s\n" "$f" "${first:-<no prompt>}"; done'

  local selected
  selected=$(eval "$list_cmd" | fzf \
    --multi \
    --delimiter=$'\t' \
    --with-nth=2 \
    --preview '
      f={1}
      echo "File:     $f"
      echo "Modified: $(stat -f "%Sm" "$f")"
      echo "Size:     $(du -h "$f" | cut -f1)"
      echo "Messages: $(wc -l < "$f" | tr -d " ")"
      echo ""
      echo "=== Conversation ==="
      jq -r "select(.type==\"user\" and (.isMeta // false | not)) | \"USER: \" + .message.content" "$f" 2>/dev/null | head -50
    ' \
    --preview-window=right:60%:wrap \
    --bind "ctrl-d:execute-silent(rm -f {+1})+reload($list_cmd)" \
    --header 'tab=select  enter=resume  ctrl-d=delete selected  esc=cancel')

  [ -z "$selected" ] && return
  local file=$(echo "$selected" | head -1 | cut -f1)
  claude --resume "$(basename "$file" .jsonl)"
}

# Browse, preview, resume, or delete Claude sessions across ALL projects
cc-sessions-all() {
  if ! ls ~/.claude/projects/*/*.jsonl >/dev/null 2>&1; then
    echo "No Claude sessions found"
    return 1
  fi

  local list_cmd='for f in $(ls -t ~/.claude/projects/*/*.jsonl 2>/dev/null); do cwd=$(jq -r '"'"'select(.cwd) | .cwd'"'"' "$f" 2>/dev/null | head -1); short=$(echo "${cwd:-unknown}" | sed "s|^/Users/[^/]*/||"); first=$(jq -r '"'"'select(.type=="user" and (.isMeta // false | not)) | .message.content'"'"' "$f" 2>/dev/null | grep -v "^<" | head -1 | cut -c1-60); printf "%s\t[%-30s] %s\n" "$f" "${short:0:30}" "${first:-<no prompt>}"; done'

  local selected
  selected=$(eval "$list_cmd" | fzf \
    --delimiter=$'\t' \
    --with-nth=2 \
    --preview '
      f={1}
      cwd=$(jq -r "select(.cwd) | .cwd" "$f" 2>/dev/null | head -1)
      echo "Project:  ${cwd:-unknown}"
      echo "File:     $f"
      echo "Modified: $(stat -f "%Sm" "$f")"
      echo "Size:     $(du -h "$f" | cut -f1)"
      echo "Messages: $(wc -l < "$f" | tr -d " ")"
      echo ""
      echo "=== Conversation ==="
      jq -r "select(.type==\"user\" and (.isMeta // false | not)) | \"USER: \" + .message.content" "$f" 2>/dev/null | head -50
    ' \
    --preview-window=right:60%:wrap \
    --bind "ctrl-d:execute(printf \"delete this session? [y/N] \"; read ans; [ \"\$ans\" = \"y\" ] && rm -f {1})+reload($list_cmd)" \
    --header 'enter=resume in original cwd  ctrl-d=delete (with confirm)  esc=cancel')

  [ -z "$selected" ] && return
  local file=$(echo "$selected" | cut -f1)
  local cwd=$(jq -r 'select(.cwd) | .cwd' "$file" 2>/dev/null | head -1)
  if [ -n "$cwd" ] && [ -d "$cwd" ]; then
    (cd "$cwd" && claude --resume "$(basename "$file" .jsonl)")
  else
    echo "Could not determine original cwd for this session; resuming from current directory"
    claude --resume "$(basename "$file" .jsonl)"
  fi
}
