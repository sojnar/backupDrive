#!/bin/bash

read -p "Digite o seu login do google sem o @gmail.com: " login
stty -echo
read -p "Difige sua senha do email google: " password
stty echo

installGdrive(){
  link64="https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download"
  link32="https://docs.google.com/uc?id=0B3X9GlR6EmbnLV92dHBpTkFhTEU&export=download"
  arch=$(uname -m)
  if [ $arch -eq x86_64 ]
  then
    wget $link64 -O /bin/gdrive
  else
    wget $link32 -O /bin/gdrive
  fi
}

sendMail(){
  read -p "Deseja configurar e-mail para envio do status do backup (s|n)" resp
  if [ $resp -eq s ] || [ $resp -eq S ]
  then
    read -p "Digite o e-mail para recebimento: " mail
  elif [ $resp -eq n ] || [ $resp -eq N ]
  then
    installMutt
  else
    echo "Opção escolhida invalida!"
    sendMail
  fi
}

installMutt(){
  versionUbuntu=$(cat /proc/version | grep -i ubuntu > /dev/null ; echo $?)
  versionCentos=$(cat /proc/version | grep -i 'red hat' > /dev/null ; echo $?)
  if [ '$versionUbuntu' -eq '0' ]
  then
    apt -f install -y
    apt install mutt -y
    apt update -y
  elif [ '$versionCentos' -eq '0' ]
  then
    yum install mutt -y
    yum update -y
  fi
}

allowToken(){
  echo "https://accounts.google.com/o/oauth2/auth?access_type=offline&client_\
  id=367116221053-7n0vf5akeru7on6o2fjinrecpdoe99eg.apps.googleusercontent.com\
  &redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=\
  https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive&state=state" > linkemail
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

    # Special Keybindings.
    bind editor <space> noop
    macro index gi \"<change-folder>=INBOX<enter>\" \"Go to inbox\"
    macro index ga \"<change-folder>=[Gmail]/All Mail<enter>\" \"Go to all mail\"
    macro index gs \"<change-folder>=[Gmail]/Sent Mail<enter>\" \"Go to Sent Mail\"
    macro index gd \"<change-folder>=[Gmail]/Drafts<enter>\" \"Go to drafts\"

    # Mutt Session Security.
    set move = no
    set imap_keepalive = 900

    # Cores.
    color hdrdefault cyan default
    color attachment yellow default
    color header brightyellow default \"Subject: \"
    color header brightyellow default \"Date: \"
    color header brightyellow default \"From: \"
    color quoted green default
    color quoted1 cyan default
    color quoted2 green default
    color quoted3 cyan default
    color error   red       default
    color message  white      default
    color indicator white      red
    color status  white      blue
    color tree   red       default
    color search  white      blue
    color markers  red       default
    color index   yellow default '~O'
    color index   yellow default '~N'
    color index   brightred    default '~F'
    color index   blue default  '~D'

    # Cores.

    # emails.
    color body  brightred black [\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+

    # URLs.
    color body  brightblue black (https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+
  " > ~/.muttrc
}

startBackupMysql(){

}

configMutt
