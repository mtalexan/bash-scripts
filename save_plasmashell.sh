#!/bin/bash
#
# 1: Name to give it

if [ -z "${1}" ] ; then
    echo "ERROR: No name given for configuration"
    exit 1
fi

# exit and wait so all settings get saved out
echo "Halting plasmashell"
kquitapp plasmashell
 echo "Waiting to finish shutdown..."
 sleep 20s
 echo "Saving"
 mkdir -p $HOME/plasma-config/${1}
 cp ~/.config/plasma* $HOME/plasma-config/${1}
 echo "Restarting"
# restart now that we're done
plasmashell &
