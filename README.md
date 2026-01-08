# Dotfiles

My personal shell configuration.

## What's included

- `zshrc` - Main zsh config
- `zsh/` - Modular zsh configuration
  - `exports.zsh` - PATH and environment variables
  - `aliases.zsh` - Short command aliases
  - `functions.zsh` - Custom shell functions

## Custom functions

| Function | Description |
|----------|-------------|
| `cpfile` | Copy file to clipboard (works with Universal Clipboard) |
| `cptext` | Copy file contents to clipboard |
| `md2pdf` | Convert markdown to PDF |
| `md2docx` | Convert markdown to Word doc (for Google Docs) |
| `md2html` | Convert markdown to styled HTML |
| `html2pdf` | Convert HTML to PDF (via Chrome) |
| `pdf2text` | Extract text from PDF |

## Installation

```bash
git clone https://github.com/USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## Requirements

- macOS
- zsh
- pandoc (for md2pdf, md2html)
- Google Chrome (for html2pdf)
- pdftotext (for pdf2text) - `brew install poppler`
