#!/bin/bash

installGdrive(){
  link64="https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download"
  link32="https://docs.google.com/uc?id=0B3X9GlR6EmbnLV92dHBpTkFhTEU&export=download"
  arch=$(uname -m)
  if [ $arch -eq x86_64 ]
  then
    wget $link64 -O /bin/gdrive
    chmod +x /bin/gdrive
  else
    wget $link32 -O /bin/gdrive
    chmod +x /bin/gdrive
  fi
}

sendMail(){
  echo
  read -p "Deseja configurar e-mail para envio do status do backup (s|n): " resp
  if [ $resp == s ] || [ $resp == S ]
  then
    read -p "Digite o e-mail para recebimento: " mail
    installGdrive
    installMutt
    configMutt
  elif [ $resp == n ] || [ $resp == N ]
  then
    installMutt
    configMutt
  else
    echo "Opção escolhida invalida!"
    sendMail
  fi
}

installMutt(){
  versionUbuntu=$(cat /proc/version | grep -i ubuntu > /dev/null ; echo $?)
  versionCentos=$(cat /proc/version | grep -i 'red hat' > /dev/null ; echo $?)
  if [ $versionUbuntu -eq 0 ]
  then
    apt -f install -y
    apt install mutt -y
    apt update -y
  elif [ $versionCentos -eq 0 ]
  then
    yum install mutt -y
    yum update -y
  fi
}

allowToken(){
  echo -n "Para a syncronização com o GoogleDrive é necessário a ativação\
  do token abaixo!"
  echo "https://accounts.google.com/o/oauth2/auth?access_type=offline&client_\
  id=367116221053-7n0vf5akeru7on6o2fjinrecpdoe99eg.apps.googleusercontent.com\
  &redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=\
  https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive&state=state" > linkemail
  echo -n "Verifique o email de confirmação enviado para $login@gmail"
  avaliableToken
  echo -n
  tokenGdrive
}

configMutt(){
  echo "
    # Conta Gmail.
    set from = \"$login@gmail.com\"
    set realname = \"$login\"
    set imap_user = \"$login@gmail.com\"
    set imap_pass = \"$password\"

    # Editor padrão.
    set editor=nano

    # Pastas IMAP.
    set folder = \"imaps://imap.gmail.com:993\"
    set spoolfile = \"+INBOX\"
    set postponed = \"+[Gmail]/Drafts\"

    # Pastas Locais.
    set header_cache =~/.mutt/cache/headers
    set message_cachedir =~/.mutt/cache/bodies
    set certificate_file =~/.mutt/certificates

    # SMTP Config.
    set smtp_url = \"smtp://$login@smtp.gmail.com:587/\"
    set smtp_pass = \"$password\"
  " > ~/.muttrc
  allowToken
}



tokenGdrive(){
  gdrive list 
}

#startBackupMysql(){

#}

authRoot(){
  auth=$(whoami)
  if [ $auth -lt root ]
  then
    echo "Esse programa deve ser executado como root!"
  else
    read -p "Digite o seu login do google sem o @gmail.com: " login
    stty -echo
    read -p "Difige sua senha do email google: " password
    stty echo ; sendMail
  fi
}

authRoot
