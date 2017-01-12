#!/bin/bash

if [ ! ${#} -ge 2 ]; then
    echo 1>&2 "Usage: ${0} LOCAL REMOTE [MERGED [BASE]]"
    echo 1>&2 "       (LOCAL, REMOTE, MERGED, BASE can be provided by \`git mergetool'.)"
    exit 1
fi

if [ ${#} -eq 2 ]; then
    # for the direct command line usage, allow only 2 arguments and trigger the behavior
    # as if there is no merged version specified
    _LOCAL=$1
    _REMOTE=$2
    _MERGED=$_REMOTE
else
    # Normal script usage specifies 3 or 4 arguments
    _LOCAL=$1
    _REMOTE=$2
    _MERGED=$3    
fi

#Store the arguments in a better way
_EVAL=
if [ $_REMOTE = $_MERGED ] ; then
    echo 1>&2 "Merge files"
    _EVAL="ediff \"$_LOCAL\" \"$_REMOTE\""
elif [ $4 -a -r $4 ] ; then
    echo 1>&2 "Merge files with ancestor and result"
    _BASE=$4
    _EVAL="ediff-merge-files-with-ancestor \"$_LOCAL\" \"$_REMOTE\" \"$_BASE\" nil \"$_MERGED\""
else
    echo 1>&2 "Merge files with result"
    _EVAL="ediff-merge-files \"$_LOCAL\" \"$_REMOTE\" nil \"$_MERGED\""
fi

# Must wait for return, so no -n allowed
echo 1>&2 "Attempting: \"$_EVAL\""
echo 1>&2 ""
emacsclient -s $EMACS_DAEMON_NAME -a "" -q -c --eval "($_EVAL)" 2>&1 >/dev/null

# Confirm the merged file exists (meaning we actually saved it when it was a newly created fil)
if [ -f $_MERGED ] ; then
    # Check for conflict markers left in the file
    if [ ! $(egrep -c '^(<<<<<<<|=======|>>>>>>>|####### Ancestor)' $_MERGED) = 0 ] ; then
        # create a temp file in the directory of the file being merged
        _MERGEDSAVE=$(mktemp --tmpdir `basename $_MERGED` .XXXXXXXXXX)
        # copy the currently saved changes to the temporary file
        cp $_MERGED $_MERGEDSAVE
        echo 1>&2 "Oops! Conflict markers detected in $_MERGED."
        echo 1>&2 "Saved your changes to $_MERGEDSAVE"
        echo 1>&2 "Exiting with code 1."
        exit 1
    fi
else
    exit 1
fi

exit 0    
