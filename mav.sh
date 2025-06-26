#!/bin/bash

# 显示帮助信息
show_help() {
    echo "MAV - 文件整理工具"
    echo ""
    echo "用法: mav [目录]"
    echo ""
    echo "功能: 根据文件名前缀（格式：字母数字-数字）自动整理文件到对应文件夹"
    echo ""
    echo "参数:"
    echo "  目录    要整理的目录路径（默认为当前目录）"
    echo ""
    echo "选项:"
    echo "  -h, --help    显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  mav .         整理当前目录"
    echo "  mav /path/to/dir    整理指定目录"
}

# 检查帮助参数
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# 获取目标目录，默认为当前目录
target_dir="${1:-.}"

# 检查目录是否存在
if [ ! -d "$target_dir" ]; then
  echo "❌ 错误: 目录 '$target_dir' 不存在"
  echo "使用 'mav --help' 查看使用帮助"
  exit 1
fi

# 切换到目标目录
cd "$target_dir" || exit 1

logfile="move.log"
echo "🔄 文件整理开始：$(date)" > "$logfile"
echo "📁 整理目录: $(pwd)" >> "$logfile"

for file in *; do
  # 忽略目录和 .log 文件
  if [ -f "$file" ] && [[ "$file" != *.log ]]; then
    # 提取前缀并转小写
    prefix=$(echo "$file" | grep -oE '^[a-zA-Z0-9]+-[0-9]+' | tr '[:upper:]' '[:lower:]')
    if [ -n "$prefix" ]; then
      mkdir -p "$prefix"
      mv -f -- "$file" "$prefix/"
      echo "✅ 移动（覆盖）: \"$file\" → \"$prefix/\"" >> "$logfile"
    else
      echo "⚠️ 忽略: \"$file\"（未匹配到前缀）" >> "$logfile"
    fi
  fi
done

echo "✅ 文件整理完成：$(date)" >> "$logfile"
echo "📋 日志文件: $(pwd)/$logfile"