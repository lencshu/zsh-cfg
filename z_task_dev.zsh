# 简洁优雅的开发环境启动脚本
# 同时启动前后端服务，后端使用docker-compose，前端使用npm，日志分别重定向到不同文件

tsdev() {
    echo "🚀 启动完整开发环境..."
    echo "📍 当前目录: $(basename "$PWD")"
    
    # 解析参数
    local enable_worker=0
    while getopts ":w" opt; do
        case $opt in
            w)
                enable_worker=1
                ;;
        esac
    done
    shift $((OPTIND - 1))
    
    # 确保日志目录存在
    mkdir -p ./_logs
    
    # 归档现有日志文件
    echo "📦 归档现有日志文件..."
    local archived_logs_dir="./_logs/_archived_logs"
    mkdir -p "$archived_logs_dir"
    
    # 查找并移动所有.log文件到归档目录
    local log_files=($(find ./_logs -maxdepth 1 -name "*.log" -type f 2>/dev/null))
    if [[ ${#log_files[@]} -gt 0 ]]; then
        echo "📋 发现 ${#log_files[@]} 个日志文件，正在归档..."
        for log_file in "${log_files[@]}"; do
            local filename=$(basename "$log_file")
            echo "   📁 归档: $filename"
            mv "$log_file" "$archived_logs_dir/"
        done
        echo "✅ 日志归档完成"
    else
        echo "📝 无需归档的日志文件"
    fi
    
    # 生成带时间戳的日志文件名
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backend_log_file="./_logs/${timestamp}_runb.log"
    local frontend_log_file="./_logs/${timestamp}_runf.log"
    local worker_log_file
    if [[ $enable_worker -eq 1 ]]; then
        worker_log_file="./_logs/${timestamp}_runw.log"
    fi
    echo "📝 后端日志文件: $backend_log_file"
    echo "📝 前端日志文件: $frontend_log_file"
    if [[ $enable_worker -eq 1 ]]; then
        echo "📝 Worker 日志文件: $worker_log_file"
    fi
    
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
        
        # 检查前端进程（通过端口检查）
        if lsof -i :3000 >/dev/null 2>&1; then
            echo "⚠️  检测到端口3000被占用（可能是前端服务），请手动停止相关进程"
            echo "💡 可以使用命令: lsof -ti:3000 | xargs kill -9"
            echo "Killing..."
            lsof -ti:3000 | xargs kill -9
        fi
        
        # 如需，检查 temporal-worker 服务
        if [[ $enable_worker -eq 1 ]]; then
            local worker_container=$(docker-compose ps -q temporal-worker 2>/dev/null)
            if [[ -n "$worker_container" ]] && docker ps -q --no-trunc | grep -q "$worker_container"; then
                echo "⚠️  检测到 temporal-worker 正在运行，停止现有服务..."
                docker-compose stop temporal-worker
                docker-compose rm -f temporal-worker
            fi
        fi
        
        echo "✅ 服务检查完成"
    }
    
    # 优雅清理函数（处理前后端）
    cleanup_services() {
        echo ""
        echo "🛑 正在停止开发环境..."
        
        # 停止后端docker服务
        docker-compose stop app 2>/dev/null || true
        
        # 停止 temporal-worker（如已启用）
        if [[ $enable_worker -eq 1 ]]; then
            docker-compose stop temporal-worker 2>/dev/null || true
        fi
        
        # 停止前端npm进程
        if [[ -n "$frontend_pid" ]]; then
            echo "🎨 停止前端服务..."
            kill -TERM "$frontend_pid" 2>/dev/null || true
            # 等待进程优雅退出
            sleep 2
            # 如果还在运行，强制停止
            kill -KILL "$frontend_pid" 2>/dev/null || true
        fi
        
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
    check_and_handle_services || return 1
    
    # 检查front目录是否存在
    if [[ ! -d "front" ]]; then
        echo "❌ 未找到front目录，请确保在正确的项目根目录中运行"
        return 1
    fi
    
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
    if [[ $enable_worker -eq 1 ]]; then
        echo "   Worker: $worker_log_file"
    fi
    echo ""
    
    # 启动后端服务（docker-compose）
    echo "🔧 启动后端服务..."
    docker-compose up app > "$backend_log_file" 2>&1 &
    local backend_pid=$!
    
    # 启动前端服务（npm）
    echo "🎨 启动前端服务..."
    (cd front && npm install && npm run dev) > "$frontend_log_file" 2>&1 &
    local frontend_pid=$!
    
    # 启动 temporal-worker（如指定）
    local worker_pid
    if [[ $enable_worker -eq 1 ]]; then
        echo "🕒 启动 temporal-worker..."
        docker-compose up temporal-worker > "$worker_log_file" 2>&1 &
        worker_pid=$!
    fi
    
    echo "✅ 前后端服务已启动"
    if [[ $enable_worker -eq 1 ]]; then
        echo "📊 服务进程 ID: 后端=$backend_pid, 前端=$frontend_pid, Worker=$worker_pid"
    else
        echo "📊 服务进程 ID: 后端=$backend_pid, 前端=$frontend_pid"
    fi
    echo ""
    echo "💡 实时查看日志:"
    echo "   后端日志: view_logs"
    echo "   前端日志: view_frontend_logs"
    echo "   服务状态: show_status"
    echo ""
    
    # 等待任一服务退出
    if [[ $enable_worker -eq 1 ]]; then
        wait $backend_pid $frontend_pid $worker_pid
    else
        wait $backend_pid $frontend_pid
    fi
    
    # 清理 trap
    trap - INT TERM
}

# 辅助函数：显示服务状态
show_status() {
    echo "📊 服务状态:"
    echo ""
    
    # 显示关键服务状态
    echo "🔍 关键服务状态:"
    
    # 检查后端服务（docker）
    local backend_container=$(docker-compose ps -q app 2>/dev/null)
    if [[ -n "$backend_container" ]] && docker ps -q --no-trunc | grep -q "$backend_container"; then
        echo "   ✅ app (后端): 运行中"
    else
        echo "   ❌ app (后端): 已停止"
    fi
    
    # 检查前端服务（npm进程 + 端口）
    if lsof -i :3000 >/dev/null 2>&1; then
        local frontend_process=$(lsof -ti:3000 2>/dev/null)
        echo "   ✅ front (前端): 运行中 (PID: $frontend_process)"
    else
        echo "   ❌ front (前端): 已停止"
    fi
    
    # 检查数据库服务（docker）
    local db_container=$(docker-compose ps -q db 2>/dev/null)
    if [[ -n "$db_container" ]] && docker ps -q --no-trunc | grep -q "$db_container"; then
        echo "   ✅ db (数据库): 运行中"
    else
        echo "   ❌ db (数据库): 已停止"
    fi
    
    echo ""
    echo "🔌 端口占用状态:"
    for port in 8000 3000 5432; do
        if lsof -i :$port >/dev/null 2>&1; then
            local process_info=$(lsof -i :$port | tail -n 1 | awk '{print $2, $1}')
            echo "   ✅ 端口 $port: 已占用 (PID: $process_info)"
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
    
    # 检查front目录是否存在
    if [[ ! -d "front" ]]; then
        echo "❌ 未找到front目录，请确保在正确的项目根目录中运行"
        return 1
    fi
    
    # 确保日志目录存在
    mkdir -p ./_logs
    
    # 生成带时间戳的前端日志文件名
    local frontend_log_file="./_logs/runf_$(date +%Y%m%d_%H%M%S).log"
    echo "📝 前端日志文件: $frontend_log_file"
    
    # 检查前端是否已在运行
    if lsof -i :3000 >/dev/null 2>&1; then
        echo "⚠️  端口3000已被占用，可能前端服务已在运行"
        echo "💡 可以使用命令停止: lsof -ti:3000 | xargs kill -9"
        read -p "是否继续启动？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ 用户取消启动"
            return 1
        fi
    fi
    
    # 启动前端服务并重定向日志
    echo "🔧 启动前端服务..."
    cd front && npm install && npm run dev 2>&1 | tee "../$frontend_log_file"
}

# 辅助函数：启动前端（后台模式）
start_frontend_daemon() {
    echo "🎨 启动前端服务（后台模式）..."
    
    # 检查front目录是否存在
    if [[ ! -d "front" ]]; then
        echo "❌ 未找到front目录，请确保在正确的项目根目录中运行"
        return 1
    fi
    
    # 确保日志目录存在
    mkdir -p ./_logs
    
    # 生成带时间戳的前端日志文件名
    local frontend_log_file="./_logs/runf_$(date +%Y%m%d_%H%M%S).log"
    echo "📝 前端日志文件: $frontend_log_file"
    
    # 检查前端是否已在运行
    if lsof -i :3000 >/dev/null 2>&1; then
        echo "⚠️  端口3000已被占用，可能前端服务已在运行"
        echo "💡 可以使用命令停止: lsof -ti:3000 | xargs kill -9"
        read -p "是否继续启动？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ 用户取消启动"
            return 1
        fi
    fi
    
    # 启动前端服务（后台模式）并重定向日志
    echo "🔧 启动前端服务（后台模式）..."
    nohup bash -c "cd front && npm install && npm run dev" > "$frontend_log_file" 2>&1 &
    local frontend_pid=$!
    
    echo "✅ 前端服务已在后台启动"
    echo "📝 前端日志: $frontend_log_file"
    echo "📊 前端进程 ID: $frontend_pid"
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
    echo "  tsdev                    - 启动完整开发环境（后端docker + 前端npm，日志分离）"
    echo "  show_status              - 显示服务状态"
    echo "  start_frontend           - 单独启动前端服务（npm run dev，前台）"
    echo "  start_frontend_daemon    - 单独启动前端服务（npm run dev，后台）"
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
    echo "  ✅ 混合启动模式：后端docker + 前端npm"
    echo "  ✅ 前后端日志分别保存到不同文件"
    echo "  ✅ 自动归档旧日志文件到 _logs/_archived_logs 目录"
    echo "  ✅ 优雅的中断处理，支持Ctrl+C停止"
    echo "  ✅ 自动检查端口占用和目录结构"
    echo ""
    echo "技术栈:"
    echo "  🔧 后端: docker-compose up app"
    echo "  🎨 前端: cd front && npm install && npm run dev"
    echo "  🗄️ 数据库: docker-compose up -d db"
    echo ""
    echo "日志文件格式:"
    echo "  后端: ./_logs/runb_YYYYMMDD_HHMMSS.log"
    echo "  前端: ./_logs/runf_YYYYMMDD_HHMMSS.log"
    echo "  归档: ./_logs/_archived_logs/"
    echo ""
    echo "示例:"
    echo "  tsdev                    # 同时启动：docker后端 + npm前端"
    echo "  start_frontend           # 单独启动前端: cd front && npm run dev"
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
    echo ""
    echo "故障排除:"
    echo "  - 端口3000被占用: lsof -ti:3000 | xargs kill -9"
    echo "  - 前端目录不存在: 确保在项目根目录运行"
    echo "  - npm依赖问题: cd front && npm install"
} 