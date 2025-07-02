# 简洁优雅的开发环境启动脚本
# 同时启动前后端服务，保护数据库数据，日志分别重定向到不同文件

tsdev() {
    echo "🚀 启动完整开发环境..."
    echo "📍 当前目录: $(basename "$PWD")"
    
    # 确保日志目录存在
    mkdir -p ./_logs
    
    # 生成带时间戳的日志文件名
    local backend_log_file="./_logs/runb_$(date +%Y%m%d_%H%M%S).log"
    local frontend_log_file="./_logs/runf_$(date +%Y%m%d_%H%M%S).log"
    echo "📝 后端日志文件: $backend_log_file"
    echo "📝 前端日志文件: $frontend_log_file"
    
    # 检查并处理现有服务
    check_and_handle_services() {
        echo "🔍 检查现有服务状态..."
        
        # 检查后端容器
        local backend_container=$(docker-compose ps -q app 2>/dev/null)
        if [[ -n "$backend_container" ]] && docker ps -q --no-trunc | grep -q "$backend_container"; then
            echo "⚠️  检测到后端服务正在运行，停止现有服务..."
            docker-compose stop app
            docker-compose rm -f app
        fi
        
        # 检查前端容器
        local frontend_container=$(docker-compose ps -q front 2>/dev/null)
        if [[ -n "$frontend_container" ]] && docker ps -q --no-trunc | grep -q "$frontend_container"; then
            echo "⚠️  检测到前端服务正在运行，停止现有服务..."
            docker-compose stop front
            docker-compose rm -f front
        fi
        
        echo "✅ 服务检查完成"
    }
    
    # 优雅清理函数（处理前后端）
    cleanup_services() {
        echo ""
        echo "🛑 正在停止开发环境..."
        
        # 停止前后端服务，保持数据库运行
        docker-compose stop app front 2>/dev/null || true
        
        echo "✅ 前后端服务已停止"
        echo "📊 数据库服务保持运行状态"
    }
    
    # 设置中断处理
    trap '
        cleanup_services
        echo "👋 开发环境已停止"
        exit 0
    ' INT TERM
    
    # 检查并处理现有服务
    check_and_handle_services
    
    # 确保数据库服务运行（后端依赖）
    echo "🗄️ 确保数据库服务运行..."
    docker-compose up -d db
    
    # 等待数据库启动
    echo "⏳ 等待数据库启动..."
    sleep 3
    
    echo "💡 提示: 按 Ctrl+C 停止开发环境（数据库将继续运行）"
    echo "📝 日志文件:"
    echo "   后端: $backend_log_file"
    echo "   前端: $frontend_log_file"
    echo ""
    
    # 同时启动前后端服务，使用后台进程和日志重定向
    echo "🔧 启动后端服务..."
    docker-compose up app > "$backend_log_file" 2>&1 &
    local backend_pid=$!
    
    echo "🎨 启动前端服务..."
    docker-compose up front > "$frontend_log_file" 2>&1 &
    local frontend_pid=$!
    
    echo "✅ 前后端服务已启动"
    echo "📊 服务进程 ID: 后端=$backend_pid, 前端=$frontend_pid"
    echo ""
    echo "💡 实时查看日志:"
    echo "   后端日志: view_logs"
    echo "   前端日志: view_frontend_logs"
    echo "   服务状态: show_status"
    echo ""
    
    # 等待任一服务退出
    wait $backend_pid $frontend_pid
    
    # 清理 trap
    trap - INT TERM
}

# 辅助函数：显示服务状态
show_status() {
    echo "📊 服务状态:"
    echo ""
    
    # 显示关键服务状态
    echo "🔍 关键服务状态:"
    for service in app front db; do
        local container=$(docker-compose ps -q $service 2>/dev/null)
        if [[ -n "$container" ]] && docker ps -q --no-trunc | grep -q "$container"; then
            echo "   ✅ $service: 运行中"
        else
            echo "   ❌ $service: 已停止"
        fi
    done
    
    echo ""
    echo "🔌 端口占用状态:"
    for port in 8000 3000 5432; do
        if lsof -i :$port >/dev/null 2>&1; then
            echo "   ✅ 端口 $port: 已占用"
        else
            echo "   ❌ 端口 $port: 空闲"
        fi
    done
    
    echo ""
    echo "📝 最近的日志文件:"
    echo "   后端日志:"
    ls -lt ./_logs/runb_*.log 2>/dev/null | head -3 || echo "     无后端日志文件"
    echo "   前端日志:"
    ls -lt ./_logs/runf_*.log 2>/dev/null | head -3 || echo "     无前端日志文件"
}

# 辅助函数：只清理后端
cleanup_backend_only() {
    echo "🧹 只清理后端服务..."
    
    # 停止后端服务
    docker-compose stop app 2>/dev/null || true
    docker-compose rm -f app 2>/dev/null || true
    
    echo "✅ 后端服务已清理"
    echo "📊 数据库和其他服务保持运行"
}

# 辅助函数：启动前端（带日志）
start_frontend() {
    echo "🎨 启动前端服务..."
    
    # 确保日志目录存在
    mkdir -p ./_logs
    
    # 生成带时间戳的前端日志文件名
    local frontend_log_file="./_logs/runf_$(date +%Y%m%d_%H%M%S).log"
    echo "📝 前端日志文件: $frontend_log_file"
    
    # 检查前端是否已在运行
    local frontend_container=$(docker-compose ps -q front 2>/dev/null)
    if [[ -n "$frontend_container" ]] && docker ps -q --no-trunc | grep -q "$frontend_container"; then
        echo "⚠️  前端服务已在运行，先停止现有服务..."
        docker-compose stop front
        docker-compose rm -f front
    fi
    
    # 启动前端服务并重定向日志
    echo "🔧 启动前端服务..."
    docker-compose up front 2>&1 | tee "$frontend_log_file"
}

# 辅助函数：启动前端（后台模式）
start_frontend_daemon() {
    echo "🎨 启动前端服务（后台模式）..."
    
    # 确保日志目录存在
    mkdir -p ./_logs
    
    # 生成带时间戳的前端日志文件名
    local frontend_log_file="./_logs/runf_$(date +%Y%m%d_%H%M%S).log"
    echo "📝 前端日志文件: $frontend_log_file"
    
    # 检查前端是否已在运行
    local frontend_container=$(docker-compose ps -q front 2>/dev/null)
    if [[ -n "$frontend_container" ]] && docker ps -q --no-trunc | grep -q "$frontend_container"; then
        echo "⚠️  前端服务已在运行，先停止现有服务..."
        docker-compose stop front
        docker-compose rm -f front
    fi
    
    # 启动前端服务（后台模式）并重定向日志
    echo "🔧 启动前端服务（后台模式）..."
    nohup docker-compose up front > "$frontend_log_file" 2>&1 &
    
    echo "✅ 前端服务已在后台启动"
    echo "📝 前端日志: $frontend_log_file"
    echo "💡 使用 view_frontend_logs 查看前端日志"
}

# 辅助函数：查看后端日志
view_logs() {
    local log_pattern="./_logs/runb_*.log"
    local latest_log=$(ls -t $log_pattern 2>/dev/null | head -1)
    
    if [[ -n "$latest_log" ]]; then
        echo "📖 查看最新后端日志: $latest_log"
        echo "================================"
        tail -f "$latest_log"
    else
        echo "❌ 未找到后端日志文件"
        echo "💡 后端日志文件格式: ./_logs/runb_YYYYMMDD_HHMMSS.log"
    fi
}

# 辅助函数：查看前端日志
view_frontend_logs() {
    local log_pattern="./_logs/runf_*.log"
    local latest_log=$(ls -t $log_pattern 2>/dev/null | head -1)
    
    if [[ -n "$latest_log" ]]; then
        echo "📖 查看最新前端日志: $latest_log"
        echo "================================"
        tail -f "$latest_log"
    else
        echo "❌ 未找到前端日志文件"
        echo "💡 前端日志文件格式: ./_logs/runf_YYYYMMDD_HHMMSS.log"
    fi
}

# 辅助函数：查看所有日志
view_all_logs() {
    echo "📊 所有日志文件:"
    echo ""
    echo "🔧 后端日志 (runb_*):"
    ls -lt ./_logs/runb_*.log 2>/dev/null || echo "   无后端日志文件"
    echo ""
    echo "🎨 前端日志 (runf_*):"
    ls -lt ./_logs/runf_*.log 2>/dev/null || echo "   无前端日志文件"
    echo ""
    
    # 提供选择查看的选项
    echo "💡 查看日志选项:"
    echo "   view_logs           - 查看最新后端日志"
    echo "   view_frontend_logs  - 查看最新前端日志"
}

# 辅助函数：清理旧日志
cleanup_old_logs() {
    local keep_days=${1:-7}  # 默认保留7天
    
    echo "🗑️ 清理 $keep_days 天前的日志文件..."
    
    # 确保日志目录存在
    mkdir -p ./_logs
    
    local deleted_count=0
    
    # 查找并删除旧的后端日志
    find ./_logs -name "runb_*.log" -mtime +$keep_days -type f 2>/dev/null | while read file; do
        echo "   删除后端日志: $file"
        rm "$file"
        ((deleted_count++))
    done
    
    # 查找并删除旧的前端日志
    find ./_logs -name "runf_*.log" -mtime +$keep_days -type f 2>/dev/null | while read file; do
        echo "   删除前端日志: $file"
        rm "$file"
        ((deleted_count++))
    done
    
    echo "✅ 日志清理完成"
    echo "📊 当前日志文件:"
    echo "   后端日志:"
    ls -lt ./_logs/runb_*.log 2>/dev/null | head -3 || echo "     无后端日志文件"
    echo "   前端日志:"
    ls -lt ./_logs/runf_*.log 2>/dev/null | head -3 || echo "     无前端日志文件"
}

# # 导出函数
# export -f tsdev show_status cleanup_backend_only start_frontend start_frontend_daemon
# export -f view_logs view_frontend_logs view_all_logs cleanup_old_logs tshelp

# 使用说明
tshelp() {
    echo "🚀 简洁开发环境管理工具"
    echo ""
    echo "主要功能:"
    echo "  tsdev                    - 启动完整开发环境（前后端同时启动，日志分离）"
    echo "  show_status              - 显示服务状态"
    echo "  start_frontend           - 单独启动前端服务（前台，带日志）"
    echo "  start_frontend_daemon    - 单独启动前端服务（后台模式）"
    echo "  cleanup_backend_only     - 只清理后端服务"
    echo ""
    echo "日志管理:"
    echo "  view_logs                - 查看最新后端日志"
    echo "  view_frontend_logs       - 查看最新前端日志"
    echo "  view_all_logs            - 显示所有日志文件"
    echo "  cleanup_old_logs [days]  - 清理旧日志文件（默认7天）"
    echo ""
    echo "特点:"
    echo "  ✅ 保护数据库数据（不会删除数据库容器）"
    echo "  ✅ 前后端同时启动，确保服务依赖（app依赖db）"
    echo "  ✅ 前后端日志分别保存到不同文件"
    echo "  ✅ 优雅的中断处理，支持Ctrl+C停止"
    echo ""
    echo "日志文件格式:"
    echo "  后端: ./_logs/runb_YYYYMMDD_HHMMSS.log"
    echo "  前端: ./_logs/runf_YYYYMMDD_HHMMSS.log"
    echo ""
    echo "示例:"
    echo "  tsdev                    # 同时启动前后端，日志分别保存"
    echo "  start_frontend           # 单独启动前端，日志保存到 ./_logs/runf_*.log"
    echo "  cleanup_old_logs 3       # 删除3天前的所有日志"
    echo "  view_logs                # 实时查看最新后端日志"
    echo "  view_frontend_logs       # 实时查看最新前端日志"
    echo ""
    echo "工作流程:"
    echo "  1. tsdev                 # 启动完整开发环境"
    echo "  2. show_status           # 检查服务状态"
    echo "  3. view_logs            # 查看后端日志"
    echo "  4. view_frontend_logs   # 查看前端日志"
    echo "  5. Ctrl+C               # 优雅停止服务"
} 