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
alias pshf='git push origin -f'
alias pll='git pull origin'
alias rbs='git rebase'
alias mge='git merge'
alias cout='git checkout'
alias fch='git fetch -a'
alias gd='git branch -D'
alias gpn='git remote prune origin'



gsq() {
    git rebase -i HEAD~"$1"
}

pm() {

    git checkout dev2 && git rebase main && git push origin dev2 && git tag "$1" && git push origin --tags
}
