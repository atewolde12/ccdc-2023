#!/bin/bash

function goto {
  label=$1
  command=$(sed -n "/^$label:/{:a;n;p;ba};" $0 | grep -v ':$')
  eval "$command"
  exit
}

os = grep -E '^ID' /etc/os-release | cut -d= -f2 | sed 's/"//g' | head -n 1

if which apt >/dev/null 2>&1; then
  echo "This system uses apt."
  pm = "apt"
elif which apt-get >/dev/null 2>&1; then
  echo "This system uses apt-get."
  pm = "apt-get"
elif which yum >/dev/null 2>&1; then
  echo "This system uses yum."
  pm = "yum"
else
  echo "Neither apt, apt-get, nor yum command is found on this system."
fi


start:
clear
echo "
  _____  __  __  _____ _____ _____   _____ 
 |  __ \|  \/  |/ ____/ ____|  __ \ / ____|
 | |__) | \  / | |   | |    | |  | | |     
 |  _  /| |\/| | |   | |    | |  | | |     
 | | \ \| |  | | |___| |____| |__| | |____ 
 |_|  \_\_|  |_|\_____\_____|_____/ \_____|"
echo "Writen by Ryan. Version 1.0"
echo "os: $os
pm: $pm"
echo "
1.) Manual package selction
2.) sbin/nologin
3.) Change/lock passwords
4.) SSHD config
5.) UFW config
6.) update && upgrade
7.) resolv.conf
8.) chmod critical
9.) Exit"
read input
if [$input == 1]; then
    goto packageSelect
elif [$input == 2]; then
    goto nologin
elif [$input == 3]; then
    goto chgpasswd
elif [$input == 4]; then
    goto SSHDconf
elif [$input == 5]; then
    goto UFWconf
elif [$input == 6]; then
    goto updategrade
elif [$input == 7]; then
    goto resolv 
elif [$input == 8]; then
    goto chmodcrit
elif [$input == 9]; then
    exit
else
    goto start
fi


#1
packageSelect:
clear
echo "Select you package manager:
1.) Apt
2.) Apt-get
3.) yum
4.) Fuck, I didn't mean to go here. Take me back"
read input
if ["$input" == 1]; then
    pm = "apt"
    echo "Apt selected"
    read -s -n 1 -p "Press any key to continue . . ."
    goto start
elif [$input == 2]; then
    pm = "apt-get"
    echo "Apt-get selected"
    read -s -n 1 -p "Press any key to continue . . ."
    goto start
elif [$input == 3]; then
    pm = "yum"
    echo "Yum selected"
    read -s -n 1 -p "Press any key to continue . . ."
    goto start
elif [$input == 4]; then
    goto start
else
    goto packageSelect
fi


#2
#idk how to use sed so change the sbin urself
nologin:
grep -v "/sbin/nologin" /etc/passwd | cut -d: -f1,3,7 
echo -e "Enter a user id to change to /sbin/nologin: (UID/-1 to exit)\n"
read input
if [$input == -1]; then
    goto start
else
    sudo nano /etc/passwd
fi
goto nologin

chgpasswd:
#3
clear
echo "Lock and change password tool:
1.) Lock root (Could be bad)
2.) Lock all service accounts (1-999)
3.) List user accounts
4.) Change User Passowrds
5.) Lock user accounts
6.) Fuck, I didn't mean to go here. Take me back"
read input
if [$input == 1]; then
    sudo passwd -l root
elif [$input == 2]; then
    for i in {1..999}
    do
        if sudo grep -q "^.*:.*:$i:" /etc/passwd; then
            sudo passwd -l $(grep "^.*:.*:$i:" /etc/passwd | cut -d':' -f1)
        fi
    done
elif [$input == 3]; then
    sudo grep "^[^:]*:[^:]*:1[0-9][0-9][0-9][^:]*:" /etc/passwd
elif [$input == 4]; then
    echo "enter UID"
    read UID
    sudo passwd $(grep "^.*:.*:$UID:" /etc/passwd | cut -d':' -f1)
elif [$input == 5]; then
    echo "enter UID"
    read UID
    sudo passwd -l $(grep "^.*:.*:$UID:" /etc/passwd | cut -d':' -f1)
elif [$input == 6]; then
    goto start
else
    goto chgpasswd
fi

#4
SSHDconf:
clear
echo "sshd config:
1.) Permitrootlogin no
2.) MaxSessions 2
3.) MaxAuthTries 3
4.) PasswordAuthentication yes
5.) PermitEmptyPasswords no
6.) All of it
7.) Exit"
read input
if [$input == 1]; then
    sudo sed -i '/[Pp][Ee][Rr][Mm][Ii][Tt][Rr][Oo][Oo][Tt][Ll][Oo][Gg][Ii][Nn]/d' /etc/ssh/sshd_config
    echo "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config
    sudo service sshd restart
elif [$input == 2]; then
    sudo sed -i '/MaxSessions/Id' /etc/ssh/sshd_config
    echo "MaxSessions 2" | sudo tee -a /etc/ssh/sshd_config
    sudo service sshd restart
elif [$input == 3]; then
    sudo sed -i '/MaxAuthTries/Id' /etc/ssh/sshd_config
    echo "MaxAuthTries 3" | sudo tee -a /etc/ssh/sshd_config
    sudo service sshd restart
elif [$input == 4]; then
    sudo sed -i '/PasswordAuthentication/Id' /etc/ssh/sshd_config
    echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
    sudo service sshd restart
elif [$input == 5]; then
    sudo sed -i '/PermitEmptyPasswords/Id' /etc/ssh/sshd_config
    echo "PermitEmptyPasswords no" | sudo tee -a /etc/ssh/sshd_config
    sudo service sshd restart
elif [$input == 6]; then
    sudo sed -i '/[Pp][Ee][Rr][Mm][Ii][Tt][Rr][Oo][Oo][Tt][Ll][Oo][Gg][Ii][Nn]/d' /etc/ssh/sshd_config
    echo "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config
    sudo sed -i '/MaxSessions/Id' /etc/ssh/sshd_config
    echo "MaxSessions 2" | sudo tee -a /etc/ssh/sshd_config
    sudo sed -i '/MaxAuthTries/Id' /etc/ssh/sshd_config
    echo "MaxAuthTries 3" | sudo tee -a /etc/ssh/sshd_config
    sudo sed -i '/PasswordAuthentication/Id' /etc/ssh/sshd_config
    echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
    sudo sed -i '/PasswordAuthentication/Id' /etc/ssh/sshd_config
    echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
    sudo sed -i '/PermitEmptyPasswords/Id' /etc/ssh/sshd_config
    echo "PermitEmptyPasswords no" | sudo tee -a /etc/ssh/sshd_config
    sudo sed -i '/PermitTunnel/Id' /etc/ssh/sshd_config
    echo "PermitTunnel no" | sudo tee -a /etc/ssh/sshd_config
    sudo service sshd restart
elif [$input == 6]; then
    goto start
fi
goto SSHDconf

#5
UFWconf:
clear
echo "UFW config:
1.) Install UFW
2.) Close all incoming ports
3.) Close all outgoing ports
4.) Open ports
5.) Exit"
if [$input == 1]; then
    if ["$pm" == "apt"]; then
        sudo apt update
        sudo apt install ufw
    elif ["$pm" == "apt-get"]; then
        sudo apt-get update
        sudo apt-get install ufw
    elif ["$on" == "yum"]; then
        sudo yum update
        sudo yum install ufw
elif [$input == 2]; then
    sudo ufw default deny incoming
elif [$input == 3]; then
    sudo ufw default allow outgoing
elif [$input == 4]; then
    echo "HTTP:80
HTTPS:443
FTP:21
FTPS & SSH:22
DNS:53
POP3:110
POP3 SSL:995
IMAP:143
IMAP SSL:993
SMTP:25 (Alternate: 26)
SMTP SSL:587

Enter port number:"
    read port
    sudo ufw allow $port/tcp
    sudo ufw allow $port/udp
elif [$input == 5]; then
    goto start
fi
goto UFWconf

#6
updategrade:
clear
echo "updating and upgrading"
if ["$pm" == "apt"]; then
    sudo apt update
    sudo apt upgrade
elif ["$pm" == "apt-get"]; then
    sudo apt-get update
    sudo apt-get upgrade
elif ["$on" == "yum"]; then
    sudo yum update
    sudo yum upgrade
fi
echo "Done :)"
read -s -n 1 -p "Press any key to continue . . ."
goto start

#7
resolv:
echo "Configing resolv.conf"
sudo rm /etc/resolv.conf
echo "#Config by rmccdc script" | sudo tee -a /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
echo "Done"
read -s -n 1 -p "Press any key to continue . . ."
goto start

#8
chmodcrit:
echo "Chmod all those important files:
1.) root 644 passwd
2.) root 644 group
3.) root 600 shadow
4.) root 600 gshadow
5.) root 644 etc/ssh
6.) Exit"
if [$input == 1]; then
    chmod 644 /etc/passwd
    chown root:root /etc/passwd
elif [$input == 2]; then
    chmod 644 /etc/group
    chown root:root /etc/group
elif [$input == 3]; then
    chmod 600 /etc/shadow
    chown root:root /etc/shadow
elif [$input == 4]; then
    chmod 600 /etc/gshadow
    chown root:root /etc/gshadow
elif [$input == 5]; then
    chmod 644 -R /etc/ssh
    chown -R root:root /etc/ssh
elif [$input == 6]; then
    goto start
fi




if [$input == 1]; then
elif [$input == 2]; then
elif [$input == 3]; then
elif [$input == 4]; then
elif [$input == 5]; then
fi