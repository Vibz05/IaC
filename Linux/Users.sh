#!/bin/bash
#
# Script name : /Linux/Users.sh
# Purpose     : Create a monthly report of user login/logout times.
# Author      : Vaibhav Revankar (L00213629)
# Date        : November 2026
#
# How it works:
#   1. The script runs every day from cron at 23:59.
#   2. It only makes the report if today is the last day of the month.
#   3. It creates /Linux/UserLogs if the folder does not exist.
#   4. It saves the report as monthyear.log (e.g. November2026.log).
#   5. The report is owned by root and set to 644, so everyone can
#      read it but a regular user cannot edit or delete it.
#
# Usage:
#   ./Users.sh           (normal use, called by cron)
#   ./Users.sh --force   (for testing, runs on any day)
#
# Cron entry (root):
#   59 23 * * * /Linux/Users.sh

LOGDIR="/Linux/UserLogs"

# Must run as root (chown and chmod need it)
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# If tomorrow is not the 1st, today is not the last day, so stop
if [ "$(date -d tomorrow +%d)" != "01" ] && [ "$1" != "--force" ]; then
    exit 0
fi

# Create the folder if it does not exist
if [ ! -d "$LOGDIR" ]; then
    mkdir -p "$LOGDIR"
fi

# Folder owned by root: users can open it but not delete files inside
chown root:root "$LOGDIR"
chmod 755 "$LOGDIR"

# Report name uses the month and year, e.g. November2026.log
REPORT="$LOGDIR/$(date +%B%Y).log"

# Write the header and the login/logout history for this month
{
    echo "User Login/Logout Report - $(date +'%B %Y')"
    echo "Generated on: $(date)"
    echo "----------------------------------------"
    last -F -w -s "$(date +%Y-%m-01)" | grep -v '^wtmp'
} > "$REPORT"

# Everyone can read it, only root can edit or delete it
chown root:root "$REPORT"
chmod 644 "$REPORT"
