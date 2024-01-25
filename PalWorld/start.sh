#!/bin/bash

ServerName=$1
ServerPassword=$2
ServerAdminPassword=$3
ServerDescription=$4
Port=$5
RCONPort=$6
Players=$7
IP=$8

rmv() {
     echo -e "stopping server"
     rcon -t rcon -a 127.0.0.1:$RCONPort -p $ServerAdminPassword -c Save && rcon -a 127.0.0.1:$RCONPort -p $ServerAdminPassword -c DoExit
}
trap rmv 15

Settings=/home/container/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini

variable_replace() {
  sed -e "s/ServerPlayerMaxNum=[0-9][0-9],/ServerPlayerMaxNum=$Players,/" -i $Settings
  sed -e "s/ServerName=[^,]*,/ServerName=\"$ServerName\",/" -i $Settings
  sed -e "s/ServerPassword=[^,]*,/ServerPassword=\"$ServerPassword\",/" -i $Settings
  sed -e "s/AdminPassword=[^,]*,/AdminPassword=\"$ServerAdminPassword\",/" -i $Settings
  sed -e "s/ServerName=[^,]*,/ServerName=\"$ServerName\",/" -i $Settings
  sed -e "s/RCONEnabled=[^,]*,/RCONEnabled=True,/" -i $Settings
  sed -e "s/RCONPort=[^,]*,/RCONPort=$RCONPort,/" -i $Settings
  sed -e "s/ServerDescription=[^,]*,/ServerDescription=\"$ServerDescription\",/" -i $Settings
}

if [[ `test -e /home/container/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini; echo $?` == 1 ]]
  then
      mkdir -p /home/container/Pal/Saved/Config/LinuxServer/
      cp /home/container/DefaultPalWorldSettings.ini /home/container/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
      variable_replace
  else
      variable_replace
fi

cd /home/container/Pal/Binaries/Linux/ && ./PalServer-Linux-Test Pal -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS -port=$Port -players=$Players -publicip $IP -publicport $Port -servername="$ServerName" EpicApp=PalServer & until echo -n ""; rcon -t rcon -a 127.0.0.1:$RCONPort -p $ServerAdminPassword 2>/dev/null; do sleep 5; done
