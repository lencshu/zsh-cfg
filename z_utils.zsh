alias profile='nano ~/.zshrc'
alias rsbt='sudo pkill bluetoothd'
alias ip='interpreter'
alias tabe='sudo nano /var/at/tabs/vi'
# export CHROME_EXECUTABLE="/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
export CHROME_EXECUTABLE="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
source /Users/vi/assurly/retroApiChatGPT/cred.sh

CUSTOM_PATHS=(
    "$HOME/bin"                      # 用户自定义脚本
    "$HOME/.amplify/bin"      # AWS Amplify CLI
    "/opt/homebrew/sbin"
    "/opt/homebrew/bin"              # Homebrew 安装的二进制文件
    "$HOME/.local/bin"
    "/Library/Frameworks/Python.framework/Versions/3.11/bin"  # Python 3.11
    "/System/Cryptexes/App/usr/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
)

# 避免重复并添加到 PATH
for path in "${CUSTOM_PATHS[@]}"; do
    [[ ":$PATH:" != *":$path:"* ]] && PATH="$path:$PATH"
done

export PATH