#!/bin/bash

# Print all systemd timers, including system-wide and all user timers.

if [ "$(id -u)" -ne 0 ]; then
  echo "Sorry, not root user."
  echo "Please use sudo or su to become root user before running this script."
  exit 1
fi

echo "System timers:"
systemctl --no-pager list-timers

usersWithActiveDbusDaemon=$(systemctl\
 --no-legend --full list-units --state=active 'user@*.service' |\
 awk '{ print substr($1, 6, length($1) - length(".service") - 5) }')

for user_uid in $usersWithActiveDbusDaemon; do
  username=$(id -nu "$user_uid")
  echo ""
  echo "Timers for $username:"
  su "$username" -c 'XDG_RUNTIME_DIR=/run/user/'"$user_uid"' systemctl --user list-timers'
done
