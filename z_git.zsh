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

pass() {
if [ -z "$1" ]; then
    echo "Usage: git_sync_to_remote <remote-url>"
    return 1
  fi

  # Step 1: 添加 remote l
  git remote add l "$1" 2>/dev/null || echo "Remote 'l' already exists. Skipping add."

  # Step 2: 获取最新信息
  git fetch origin --tags

  # Step 3: 推送函数（封装一下判断）
  push_branch_if_exists() {
    local branch="$1"
    if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      echo "Syncing branch: $branch"
      git fetch origin "$branch"
      git push l "origin/$branch:refs/heads/$branch"
    else
      echo "Branch '$branch' not found on origin. Skipping."
    fi
  }

  # Step 4: 推送 dev2 和 develop
  push_branch_if_exists "dev2"
  push_branch_if_exists "develop"

  # Step 5: 推送 master 或 main（优先 master）
  if git show-ref --verify --quiet "refs/remotes/origin/master"; then
    push_branch_if_exists "master"
  elif git show-ref --verify --quiet "refs/remotes/origin/main"; then
    push_branch_if_exists "main"
  else
    echo "Neither 'master' nor 'main' branch found on origin. Skipping."
  fi

  # Step 6: 推送所有 tags
  echo "Pushing all tags to remote 'l'..."
  git push l --tags
}