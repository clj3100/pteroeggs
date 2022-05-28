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
extra_args=${10}
automod=${11}
verify=${12}
automodvar=""

rmv() {
     echo -e "stopping server"
     rcon -t rcon -a 127.0.0.1:$RCONPort -p $ServerAdminPassword -c saveworld && rcon -a 127.0.0.1:$RCONPort -p $ServerAdminPassword -c DoExit
}
trap rmv 15

if [ -z "$mods" ]
    then
        sed -e 's/^ActiveMods=.*//' -i /home/container/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini
        echo "" > /home/container/ShooterGame/Saved/Config/WindowsServer/Game.ini
    else
        echo "[ModInstaller]" > /home/container/ShooterGame/Saved/Config/WindowsServer/Game.ini
        for id in $(echo $mods |tr "," "\n")
            do
                echo "ModIDS=$id" >> /home/container/ShooterGame/Saved/Config/WindowsServer/Game.ini
            done
        if [[ $(grep -q '^ActiveMods' ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini;echo $?) == 1 ]]
            then
                sed -e "/\[ServerSettings\]/a ActiveMods=$mods" -i /home/container/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini
            else
                sed -e "s/^ActiveMods=.*/ActiveMods=$mods/" -i /home/container/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini
        fi
fi

if [[ $verify == 1 ]]
    then
        cd /home/container/steamcmd && ./steamcmd.sh +force_install_dir /home/container +login anonymous +@sSteamCmdForcePlatformType windows +app_update 376030 validate +quit
fi

sed -e "s/MaxPlayers.*/MaxPlayers=$Players/" -i /home/container/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini

xvfb-run --auto-servernum wine /home/container/ShooterGame/Binaries/Win64/ShooterGameServer "$map?listen?SessionName="$SessionName"?ServerPassword=$ServerPassword?ServerAdminPassword=$ServerAdminPassword?Port=$Port?RCONPort=$RCONPort?QueryPort=$QueryPort?RCONEnabled=True?MaxPlayers=$Players"$( [ "$BATTLE_EYE" == "1" ] || printf %s ' -NoBattlEye' ) -server $automodvar $extra_args -log & until echo -n ""; rcon -t rcon -a 127.0.0.1:$RCONPort -p $ServerAdminPassword 2>/dev/null; do sleep 5; done