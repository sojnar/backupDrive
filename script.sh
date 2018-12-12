#!/bin/bash

read -p "Digite o seu login do google sem o @gmail.com: " login
stty -echo
read -p "Difige sua senha do email google: " password
stty echo

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
configMutt
