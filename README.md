# List all systemd timers script

Two examples of how to show all systemd timers running on the current system.
Requires root access.

## Explanation

Thanks to the Freenode #systemd IRC channel (users dreisner and damjan),
I learned that systemd requires the user to run `systemctl --user list-timers`
in order to print the running timers. 

If an administrator of the system wants to `sudo` or `su` as another user in order to
see the tiemrs, then they need to set `XDG_RUNTIME_DIR` envrionment variable.

The code here automates this process and shows all the running timers.

## Implementation

I first implemented the script using Haskell, but felt like the problem was
a good fit for Bash. So, I implemented another script using bash.

The user output should be identical between the scripts. Both require the user running
the script to be root.

## Example 

```
$ sudo ./list-all-systemd-timers.hs
[sudo] password for david:
System timers:
NEXT                         LEFT         LAST                         PASSED  UNIT             ACTIVATES
Sun 2016-10-02 22:34:40 EDT  38min left   Sat 2016-10-01 22:34:40 EDT  23h ago systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
Mon 2016-10-03 00:00:00 EDT  2h 3min left Sun 2016-10-02 00:01:40 EDT  21h ago logrotate.timer             logrotate.service
Mon 2016-10-03 00:00:00 EDT  2h 3min left Sun 2016-10-02 00:01:40 EDT  21h ago man-db.timer             man-db.service
Mon 2016-10-03 00:00:00 EDT  2h 3min left Sun 2016-10-02 00:01:40 EDT  21h ago shadow.timer             shadow.service

4 timers listed.
Pass --all to see loaded but inactive timers, too.

Timers for david:
0 timers listed.
Pass --all to see loaded but inactive timers, too.

Timers for tester:
0 timers listed.
Pass --all to see loaded but inactive timers, too.
```
