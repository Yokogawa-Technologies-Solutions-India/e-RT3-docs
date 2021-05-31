#!/usr/bin/env bash

# -------------------------------------------------------------------------
# Copyright (c) 2021 Yokogawa Technologies Solutions India Pvt. Ltd.
#
# All rights reserved.
#
# Licensed under the MIT License. See LICENSE FILE in the project root for
# license information.
# --------------------------------------------------------------------------

LICENSE_FILE="LICENSE"
while IFS= read -r line
do
    echo "$line"
done < $LICENSE_FILE
echo ""
echo ""
DEST="/lib/systemd/system"
PROJECT_DIR="$(pwd)"
SERVICE_NAME="sample-ai-application"
SERVICE_FILE="$DEST/$SERVICE_NAME.service"
PROJECT_FILE="sample-ai-application"

if test -f "$SERVICE_FILE"; then
    echo "$SERVICE_FILE exists. deleting it.."
    sudo service "$SERVICE_NAME" stop
    sudo systemctl disable "$SERVICE_NAME"
    sudo systemctl daemon-reload    
    sudo rm -rf "$SERVICE_FILE"
    echo "$SERVICE_FILE deleted."
fi

chmod +x "$PROJECT_DIR/$PROJECT_FILE"

echo "creating a service"
touch "$SERVICE_FILE"
chmod 777 "$SERVICE_FILE"
echo "# -------------------------------------------------------------------------" >> "$SERVICE_FILE"
while IFS= read -r line
do
    echo "# $line" >> "$SERVICE_FILE"
done < $LICENSE_FILE
echo "# -------------------------------------------------------------------------" >> "$SERVICE_FILE"
echo "" >> "$SERVICE_FILE"
echo "[Unit]" >> "$SERVICE_FILE"
echo "Description=Sample AI application Flask web server" >> "$SERVICE_FILE"
echo "[Install]" >> "$SERVICE_FILE"
echo "WantedBy=multi-user.target" >> "$SERVICE_FILE"
echo "[Service]" >> "$SERVICE_FILE"
echo "User=ert3" >> "$SERVICE_FILE"
echo "PermissionsStartOnly=true" >> "$SERVICE_FILE"
echo "ExecStart=/bin/bash -c 'cd $PROJECT_DIR && ./$PROJECT_FILE'" >> "$SERVICE_FILE"
echo "TimeoutSec=600" >> "$SERVICE_FILE"
echo "Restart=on-failure" >> "$SERVICE_FILE"
echo "RuntimeDirectoryMode=755" >> "$SERVICE_FILE"
echo "created a service at $SERVICE_FILE"
chmod 644 "$SERVICE_FILE"

sleep 2
cat $SERVICE_FILE

echo "reloading all services"
sudo systemctl daemon-reload
sleep 5
echo "releaded"

echo "enableing $SERVICE_NAME service"
sudo systemctl enable "$SERVICE_NAME"
sleep 5
echo "enabled"

echo "starting $SERVICE_NAME service"
sudo service "$SERVICE_NAME" start
sleep 90
echo "started $SERVICE_NAME service"