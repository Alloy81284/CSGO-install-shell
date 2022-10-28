#!/bin/bash
cd /root/csgo
./srcds_run -tickrate 128 -console -maxplayers_override -ip 0.0.0.0 -autoupdate -steam_dir "/root" -steamcmd_script "/root/update.txt"
