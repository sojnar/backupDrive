#!/bin/bash
log="/var/log/savedump.log"
data=`date +%d%m%Y`

installGdrive(){
  link64="https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download"
  link32="https://docs.google.com/uc?id=0B3X9GlR6EmbnLV92dHBpTkFhTEU&export=download"
  arch=$(uname -m)
  if [ $arch == x86_64 ]
  then
    wget -b $link64 -O /bin/gdrive >> $log
    echo "Instalando Gdrive... Aguarde!"
    sleep 4
    chmod +x /bin/gdrive
  else
    wget -b $link32 -O /bin/gdrive >> $log
    echo "Instalando Gdrive... Aguarde!"
    sleep 4
    chmod +x /bin/gdrive
  fi
}

loadToken(){
  sleep 5
  gdrive list >> $log | killall -s SIGINT gdrive
  linktoken=`tail -n5 $log | grep http`
}

sendMail(){
  echo
  read -p "Deseja configurar e-mail para envio do status do backup (s|n): " resp
  if [ $resp == s ] || [ $resp == S ]
  then
    read -p "Digite o e-mail para recebimento: " mail
    installGdrive
    loadToken
    installMutt
    configMutt
    confDB
  elif [ $resp == n ] || [ $resp == N ]
  then
    installGdrive
    loadToken
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
    apt update -y >> $log 2>&1
    apt -f install -y >> $log 2>&1
    apt install mutt wget curl -y >> $log 2>&1
  elif [ $versionCentos -eq 0 ]
  then
    yum install mutt cyrus-sasl-plain wget -y >> $log 2>&1
    yum install epel-release -y
    yum install jq -y
  fi
}

allowToken(){
echo "$linktoken"
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
  avaliableToken
}

avaliableToken(){
  allowToken | mutt -s 'Validação token' $login@gmail.com
  tokenGdrive
}

tokenGdrive(){
  sleep 4
  echo -n "Verifique seu email $login@gmail.com e insira o token para validação: "
  gdrive list >> $log
}

confDB(){
  echo "Agora vamos configurar o backup do banco!"
  read -p "Digite 'p' para postgres ou 'm' para mysql: " banco
  case $banco in
    p|P)

        read -p "Deseja fazer um backup completo do banco (y|n) " dbase
        if [ $dbase == y ] || [ $dbase == Y ]
        then

            if [ ! -d "/var/backupDrive" ]
            then
                mkdir /var/backupDrive
            fi

            echo "
              pg_dumpall > /var/backupDrive/postgres_$data_all.dump
            " > backupPostgres.sh

        elif [ $dbase == n ] || [ $dbase == N ]
        then

            if [ ! -d "/var/backupDrive" ]
            then
                mkdir /var/backupDrive
            fi

            read -p "Digite o usuário do Banco: " userdb
            stty -echo
            read -p "Digite a senha do $userdb: " passdb
            stty echo

            echo "#!/bin/bash
              pg_dump -U $userdb -d $dbase > /var/backupDrive/postgres_$data_$dbase.dump
            " > backupPostgres.sh

        fi
    ;;
    m|M)

        read -p "Deseja fazer um backup completo do banco (y|n) " dbase
        if [ $dbase == y || $dbase == Y ]
        then

             if [ ! -d "/var/backupDrive" ]
             then
                  mkdir /var/backupDrive
              fi

              echo "#!/bin/bash
                mysqldump --all-databases > /var/backupDrive/mysql_$data_all.dump
              " > backupMysql.sh

        elif [ $dbase == n || $dbase == N ]
        then

            read -p "Digite o usuário do Banco: " userdb
            stty -echo
            read -p "Digite a senha do $userdb: " passdb
            stty echo

            echo "#!/bin/bash
              mysqldump -u $userdb -p $passdb $dbase > mysql_$data_$dbase.dump
             " > backupMysql.sh

        fi
    ;;
    *)
  esac
}

#startBackupMysql(){

#}

authRoot(){
  clear
  auth=$(whoami)
  if [ $auth != root ]
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
