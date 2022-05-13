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

sed -e "s/\#ark_GameModIds.*/ark_GameModIds=\"$mods\"/" -i .config/arkmanager/instances/main.cfg

bin/arkmanager installmods

cd ShooterGame/Binaries/Linux && ./ShooterGameServer $map?listen?SessionName="$SessionName"?ServerPassword=$ServerPassword?ServerAdminPassword=$ServerAdminPassword?Port=$Port?RCONPort=$RCONPort?QueryPort=$QueryPort?RCONEnabled=True$( [ "$BATTLE_EYE" == "1" ] || printf %s ' -NoBattlEye' ) -server {{ARGS}} -log & until echo "waiting for rcon connection..."; rcon -t rcon -a 127.0.0.1:$RCONPort -p $ServerAdminPassword; do sleep 5; done