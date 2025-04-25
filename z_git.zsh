alias mkenv='cp ~/mkcfg ~/.gitconfig && echo env mk'
alias glenv='cp ~/.ssh/id_rsa.pub.gl ~/.ssh/id_rsa.pub && cp ~/.ssh/id_rsa.gl ~/.ssh/id_rsa && cp ~/glcfg ~/.gitconfig && echo env gl'
alias techenv='cp ~/.ssh/id_rsa.pub.tech ~/.ssh/id_rsa.pub && cp ~/.ssh/id_rsa.tech ~/.ssh/id_rsa && cp ~/glcfg ~/.gitconfig && echo env tech'

alias ggc='git prune && git gc && git fsck'
alias gsl='git shortlog --all --summary --no-merges'
alias cf='code2flow --language py'
alias gsup='git submodule update --init'
alias gspll='git submodule foreach git pull origin'
alias gfh='git submodule foreach git'
alias gs='git submodule'
alias gtg='git tag'
alias rst='git reset'
alias rsth='git reset --hard'
alias gcp='git cherry-pick'
alias gig='git rm -r --cached .'
alias add='git add .'
alias cmt='git commit -m'
alias cma='git commit -a'
alias psh='git push origin'
alias psl='git push l'
alias grl='git remote add l'
alias pshf='git push origin -f'
alias pll='git pull origin'
alias rbs='git rebase'
alias mge='git merge'
alias cout='git checkout'
alias fch='git fetch -a'
alias gd='git branch -D'
alias gpn='git remote prune origin'

alias upmind='add && cmt updated && psh main'


gsq() {
    git rebase -i HEAD~"$1"
}

pm() {

    git checkout dev2 && git rebase main && git push origin dev2 && git tag "$1" && git push origin --tags
}

gsy() {
  if [ -z "$1" ]; then
    echo "Usage: psync <remote-url>"
    return 1
  fi

  # 保存当前分支，待会恢复
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  # 添加 remote l（如果未存在）
  if ! git remote get-url l &>/dev/null; then
    git remote add l "$1"
  else
    echo "Remote 'l' already exists. Skipping add."
  fi

  # 获取远程分支和标签
  git fetch origin --tags

  # 封装推送函数
  push_branch_if_exists() {
    local branch="$1"
    if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      echo "Syncing branch: $branch"

      # 拉取该分支
      git fetch origin "$branch"

      # 创建临时分支
      temp_branch="__tmp_sync_$branch"
      git checkout -B "$temp_branch" "origin/$branch"

      # 推送到 remote l
      git push l "$temp_branch:$branch"

      # 切回原始分支
      git checkout "$current_branch"

      # 删除临时分支
      git branch -D "$temp_branch"
    else
      echo "Branch '$branch' not found on origin. Skipping."
    fi
  }

  # 推送 dev2 和 develop
  push_branch_if_exists "dev2"
  push_branch_if_exists "develop"

  # 推送 master 或 main
  if git show-ref --verify --quiet "refs/remotes/origin/master"; then
    push_branch_if_exists "master"
  elif git show-ref --verify --quiet "refs/remotes/origin/main"; then
    push_branch_if_exists "main"
  else
    echo "Neither 'master' nor 'main' branch found on origin. Skipping."
  fi

  # 推送 tags
  echo "Pushing all tags to remote 'l'..."
  git push l --tags

  # 最后回到原来的分支（保险）
  git checkout "$current_branch"
}


function add_remote_and_push() {
  # 获取 origin 的 URL
  origin_url=$(git remote get-url origin 2> /dev/null)
  if [[ -z "$origin_url" ]]; then
    echo "❌ 当前目录不是一个有效的 git 仓库，或没有 origin remote"
    return 1
  fi

  # 提取原始项目名
  if [[ "$origin_url" == *@*:* ]]; then
    # SSH 格式：git@host:owner/project.git
    pathj=${origin_url#*:}
  else
    # HTTPS 格式：https://host/owner/project.git
    pathj=${origin_url#*://*/}
  fi
  original_proj=$(basename "${pathj}" .git)

  # 确定使用的远程项目名：优先第一个参数，否则用原名
  project=${1:-$original_proj}

  # 构造新的 remote 地址
  if [[ "$origin_url" == *@*:* ]]; then
    # SSH
    domain_and_host=${origin_url%%:*}
    new_url="${domain_and_host}:lencshu/${project}.git"
  else
    # HTTPS
    domain_prefix=$(echo "$origin_url" | sed -E 's#(https?://[^/]+)/.*#\1#')
    new_url="${domain_prefix}/lencshu/${project}.git"
  fi

  echo "✅ 原始 remote: $origin_url"
  echo "✅ 原始项目名称: $original_proj"
  echo "✅ 使用的远程项目名称: $project"
  echo "✅ 新 remote l: $new_url"

  # 添加 l remote，如果已存在则先删除
  if git remote get-url l &> /dev/null; then
    echo "remote 'l' 已存在，正在删除旧的 remote"
    git remote remove l
  fi
  git remote add l "$new_url"
  echo "✅ remote 'l' 添加成功"

  # 第二个参数为分支名，若提供则自动推送
  if [[ -n "$2" ]]; then
    branch="$2"
    echo "🚀 正在推送到 remote 'l' 的分支: $branch"
    git push l "$branch"
  else
    echo "未提供分支名，不执行 push 操作"
  fi
}