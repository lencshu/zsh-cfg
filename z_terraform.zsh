alias tf='terraform'
alias tfa='terraform apply'
alias tfp='terraform plan'
alias tfi='terraform init'
alias tfd='terraform destroy'
alias tfo='terraform output'
alias tfs='terraform show'
alias tfg='terraform graph'
alias tfw='terraform workspace'
alias tfl='terraform list'
alias tfauth='gcloud auth application-default login'

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
