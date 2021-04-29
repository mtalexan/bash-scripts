#!/bin/bash
#
# 1: Name of config to re-use



if [ -z "${1}" ] ; then
    echo "ERROR: No name given for configuration"
    # list the posssible configs
    echo "Possible options:"
    find $HOME/plasma-config/ -maxdepth 1 -mindepth 1 -type d | sed -e "s|${HOME}/plasma-config/|  |g" 2>/dev/null
    exit 1
fi
if [ ! -e "$HOME/plasma-config/${1}" ] ; then
    echo "ERROR: No such configuration exists: HOME/plasma-config/${1}"
    exit 1
fi

# exit and wait so it's actually shut down
echo "Halting plasmashell"
kquitapp plasmashell
 echo "Waiting to finish shutdown..."
 sleep 20s
 echo "Saving"
 cp $HOME/plasma-config/${1}/plasma* ~/.config/
 echo "Restarting"
# restart now that we're done
plasmashell &
