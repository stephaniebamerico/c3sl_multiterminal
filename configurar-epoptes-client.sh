#!/bin/bash
install -m 644 systemd/epoptes-client.service /etc/systemd/system
systemctl stop epoptes-client
systemctl disable epoptes-client
systemctl enable epoptes-client.service
systemctl start epoptes-client.service
