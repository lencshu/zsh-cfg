alias t='task'
alias tls='task list'
alias tb='task app:build'
alias tbw='task temporal:worker:build'
alias tts='task temporal:start'
alias ttw='task temporal:worker'
alias ttwd='task temporal:stop'


# alias tsb='t app:run 2>&1 | perl -pe "s/\x00//g; s/\e\[[0-9;]*[a-zA-Z]//g" > runb.log'

# 使用追加模式并添加时间戳，避免重复覆盖
alias tsb='echo "=== Backend started at $(date) ===" > runb.log && t app:run >> runb.log 2>&1'

alias tsf='cd front && npm install && npm run dev | tee ../runf.log'

# # 开发服务器启动命令 - 同时运行后端和前端
# tsdev() {
#     echo "🚀 启动开发环境..."
#     echo "📍 当前目录: $(basename "$PWD")"
#     echo "💡 提示: 按 Ctrl+C 中断服务"
#     echo ""
    
#     # 中断标志，防止重复处理
#     local interrupted=false
    
#     # 设置中断处理：根据当前目录决定是否返回上级目录，并显示提示信息
#     trap '
#         if [[ "$interrupted" == "false" ]]; then
#             interrupted=true
#             echo ""
#             current_dir=$(basename "$PWD")
#             if [[ "$current_dir" == "front" ]]; then
#                 echo "🔄 检测到在 front 目录中断，返回上级目录..."
#                 cd ..
#                 echo "📍 当前目录: $(basename "$PWD")"
#             else
#                 echo "⏹️  在 $current_dir 目录中断，保持当前位置"
#             fi
#             echo "✅ 开发环境正在停止..."
#             echo "⏳ 等待服务完全关闭（再次按 Ctrl+C 强制退出）..."
            
#             # 立即强制终止后台进程，避免重复写入
#             echo "🛑 正在终止后台服务..."
#             for job in $(jobs -p); do
#                 kill -KILL "$job" 2>/dev/null || true
#             done
            
#             # 短暂等待确保进程完全终止
#             sleep 1
            
#             echo "✅ 开发环境已完全停止"
#             exit 0
#         else
#             echo "🚨 强制退出所有服务..."
#             # 立即强制退出所有后台进程
#             kill -KILL $(jobs -p) 2>/dev/null || true
#             exit 0
#         fi
#     ' INT
    
#     # 同时启动后端和前端服务
#     tsb & tsf
#     wait
    
#     # 清理 trap
#     trap - INT
# }