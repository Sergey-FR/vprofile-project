#!/bin/bash

# Change directory and change ownership
cd /var/www/html/kubernetes-setup/ && sudo chown -R www-data:ubuntu .

# Change directory and change permissions
cd /var/www/html/kubernetes-setup/ && sudo chmod -R 770 .
