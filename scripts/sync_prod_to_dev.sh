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

# Tables to transfer structure only (exclude data)
EXCLUDED_TABLES=("action_log" "action_log_items" "api_call_log" "api_sent_messages" "approve_sales_stage_change_log"
"approve_session" "emaillogs" "emailtemp" "error_alarms" "failed_jobs" "jobs" "kwipped_errors" "login_tracking"
"message_queue" "message_queue_archive" "messages" "password_reminders" "password_resets" "payment_attempts"
"payment_method_cache" "personal_access_tokens" "reconciliation_log" "reply_log" "rfq_archives" "twilio_sessions"
"webhooks" "webhook_calls" "workflow_logs" "workflow_logs_archives" "userbreadcrumbs" "communications" "notifications"
"art_urls"
"r_rfqs")

# Fetch all views dynamically, and completely exclude
echo "Fetching view names from production database..."
VIEW_TABLES=$(mysql -h $PROD_HOST -u $PROD_USER -p$PROD_PASS -N -e "SELECT table_name FROM information_schema.tables WHERE table_schema='$PROD_DB' AND table_type='VIEW' AND table_name LIKE 'v_%';")

echo ${VIEW_TABLES}

VIEW_TABLE_ARRAY=($VIEW_TABLES)

echo "Skipping the following views entirely:"
printf "%s\n" "${VIEW_TABLE_ARRAY[@]}"

# Build ignore tables for full dump (manual exclusions + views)
IGNORE_TABLES=""
for TABLE in "${EXCLUDED_TABLES[@]}" "${VIEW_TABLE_ARRAY[@]}"; do
  IGNORE_TABLES+=" --ignore-table=${PROD_DB}.${TABLE}"
done



echo "Starting database sync..."
# Export full database excluding specified tables
mysqldump -h $PROD_HOST -u $PROD_USER -p$PROD_PASS \
  --routines --triggers --single-transaction --set-gtid-purged=OFF --quick --lock-tables=false --skip-lock-tables --no-tablespaces \
  --verbose $PROD_DB $IGNORE_TABLES > full_dump.sql
echo "Dumped full database excluding certain tables."
# Export structure only for excluded tables
for TABLE in "${EXCLUDED_TABLES[@]}"; do
  mysqldump -h $PROD_HOST -u $PROD_USER -p$PROD_PASS --no-data $PROD_DB $TABLE --verbose >> full_dump.sql
done

# Import into Dev
echo "Importing into dev database..."
echo "This can take a while if your comuter is slow"
mysql -h $DEV_HOST -P $DEV_PORT -u $DEV_USER -p$DEV_PASS $DEV_DB < full_dump.sql

echo "Database sync complete!"
