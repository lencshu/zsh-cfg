alias t='task'
alias tls='task list'
alias tls='task list'


# alias tsb='t app:run 2>&1 | perl -pe "s/\x00//g; s/\e\[[0-9;]*[a-zA-Z]//g" > runb.log'

alias tsb='t app:run > runb.log 2>&1'

alias tsf='cd front && npm install && npm run dev | tee ../runf.log'

alias tsdev='trap "cd ..; exit" INT; tsb & tsf; wait'