#!/bin/bash

map=$1
SessionName=$2
ServerPassword=$3
ServerAdminPassword=$4
Port=$5
RCONPort=$6
QueryPort=$7
Players=$8
mods=$9

rmv() {
     echo -e "stopping server"
     rcon -t rcon -a 127.0.0.1:$RCONPort -p $ServerAdminPassword -c saveworld && rcon -a 127.0.0.1:$RCONPort -p $ServerAdminPassword -c DoExit
}
trap rmv 15

if [[ $(test -e bin/arkmanager;echo $?) == 1 ]] 
    then
        echo "Installing Ark Server Tools"
        curl -sL https://git.io/arkmanager | bash -s -- --me --perform-user-install --yes-i-really-want-to-perform-a-user-install
        sed -e 's:arkserverroot="/home/container/ARK":arkserverroot="/home/container":' -i .config/arkmanager/instances/main.cfg
        sed -e "s/\#ark_GameModIds/ark_GameModIds/" -i .config/arkmanager/instances/main.cfg
    else
        echo "Ark Server Tools already installed"
fi

if [ -z "$mods" ]
    then
        sed -e 's/ActiveMods=.*//' -i ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini
fi
if [[ $(grep -q ActiveMods ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini;echo $?) == 1 ]]
    then
        sed -e "/\[ServerSettings\]/a ActiveMods=$mods" -i ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini
    else
        sed -e "s/ActiveMods=.*/ActiveMods=$mods/" -i ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini
fi

sed -e "s/ark_GameModIds.*/ark_GameModIds=\"$mods\"/" -i .config/arkmanager/instances/main.cfg

bin/arkmanager installmods

cd ShooterGame/Binaries/Linux && ./ShooterGameServer $map?listen?SessionName="$SessionName"?ServerPassword=$ServerPassword?ServerAdminPassword=$ServerAdminPassword?Port=$Port?RCONPort=$RCONPort?QueryPort=$QueryPort?RCONEnabled=True$( [ "$BATTLE_EYE" == "1" ] || printf %s ' -NoBattlEye' ) -server {{ARGS}} -log & until echo "waiting for rcon connection..."; rcon -t rcon -a 127.0.0.1:$RCONPort -p $ServerAdminPassword; do sleep 5; done