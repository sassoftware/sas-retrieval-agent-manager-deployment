# Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

OUTPUT_DIR="deploy"
SCRIPT_FILE="app_database_init.sql" # change with desired file
ENV_FILE=".env"

# Load env file with export
set -o allexport
source "$ENV_FILE"
set +o allexport

mkdir -p "$OUTPUT_DIR"
envsubst < "$SCRIPT_FILE" > "$OUTPUT_DIR/$SCRIPT_FILE.tmp"
mv "$SCRIPT_FILE.tmp" "$OUTPUT_DIR/$SCRIPT_FILE"

# Set password for psql
export PGPASSWORD="$ADMIN_DB_PASSWORD"

if psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_DB_USERNAME" -d "$INIT_DB_NAME" -f "$OUTPUT_DIR/$SCRIPT_FILE"; then
    echo
    echo "Script executed successfully!"
else
    echo
    echo "Script execution failed with error code: $?"
fi