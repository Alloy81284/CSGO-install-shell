#!/bin/bash
cd /home/csgo/csgo
./srcds_run -tickrate 128 -console -maxplayers_override -ip 0.0.0.0 -autoupdate -steam_dir "/home/csgo" -steamcmd_script "/home/csgo/update.txt"