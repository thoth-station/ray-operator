#!/bin/bash

# typically expecting these to be set elsewhere, for example from the Containerfile or from the kube downward API
# but here provide some hopefully sane defaults
export USER=${USER:-'anonymoususer'}
export HOME=${HOME:-'/tmp'}

# Check whether there is a passwd entry for the container UID
myuid=$(id -u)
mygid=$(id -g)
uidentry=$(getent passwd $myuid)

# If there is no passwd entry for the container UID, attempt to create one
if [ -z "$uidentry" ] ; then
    if [ -w /etc/passwd ] ; then
        echo "$myuid:x:$myuid:$mygid:${USER}:${HOME}:/bin/false" >> /etc/passwd
    else
        echo "Container 'passwd' file is not writable: entrypoint failed to add passwd entry for UID $myuid"
    fi
fi

# make modifications to incoming command here, or just pass through
CMD=("$@")

# Run the container command under tini for better hygiene
exec tini -s -- "${CMD[@]}"
