export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

alias wg='python /Users/vi/winGo.py'
alias pg311='pyenv global 3.11 && pyenv shell 3.11 && python --version'
alias pg39='pyenv global 3.9 && pyenv shell 3.9 && python --version'
alias pg313='pyenv global 3.13.7 && pyenv shell 3.13.7 && python --version'
alias pop='poetry run python'
alias po='poetry'
alias pth='pytest -vv -W ignore::DeprecationWarning --html=./_logs/report.html --self-contained-html'
alias ptm='pytest -vv -W ignore::DeprecationWarning -m'
alias pt='pytest -vv -W ignore::DeprecationWarning'
alias envon='source .venv/bin/activate'
alias envinit='virtualenv .venv'
alias pip='pip3'
alias py='python3.13'
