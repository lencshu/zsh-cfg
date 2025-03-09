export PATH="$HOME/.serverless/bin:$PATH"
alias sst='serverless test'
alias sstmf='serverless test --stage prod --function'
alias sstdf='serverless test --stage dev --function'
alias sstbf='serverless test --stage beta --function'
alias sstff='serverless test --stage feature --function'
alias sstpf='serverless test --stage preprod --function'
alias ssd='serverless deploy --force --verbose --stage'