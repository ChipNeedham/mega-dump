#!/bin/bash

set -e

# Load environment variables
source .env

# AWS RDS Credentials (set these manually or pull from AWS Secrets Manager)
PROD_HOST=$PROD_HOST
PROD_USER=$PROD_USER
PROD_PASS=$PROD_PASS
PROD_DB=$PROD_DB
PROD_PORT=3066

# Dev Credentials
DEV_HOST="127.0.0.1"
DEV_PORT=3366
DEV_USER=root
DEV_PASS=$MYSQL_ROOT_PASSWORD
DEV_DB=$MYSQL_DATABASE

# Import into Dev
mysql -h $DEV_HOST -P $DEV_PORT -u $DEV_USER -p$DEV_PASS $DEV_DB < full_dump.sql

echo "Database sync complete!"
