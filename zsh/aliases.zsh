# Custom aliases

# Reload shell config
alias reload='source ~/.zshrc'

# Flutter - clean logging in separate terminal while 'flutter run' is active
alias flogs='adb logcat -s flutter'

# Kill process on a specific port (e.g., killport 3000)
killport() { kill -9 $(lsof -t -i:$1) 2>/dev/null && echo "Killed process on port $1" || echo "No process on port $1"; }
