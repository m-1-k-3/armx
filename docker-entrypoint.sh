#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# EMUX by Saumil Shah
# https://emux.exploitlab.net/

set -e

echo [+] Starting tun0
sudo /etc/local.d/10-tun-network.start 2>&1 >/dev/null

echo [+] Starting NFS
sudo rpcbind -w
sudo rpcinfo
#sudo rpc.nfsd --no-nfs-version 2 --no-nfs-version 3 --nfs-version 4 --debug 4
sudo rpc.nfsd --debug 8
sudo rpc.nfsd --debug 8
sudo exportfs -rv
sudo exportfs
#sudo rpc.mountd --debug all --no-nfs-version 2 --no-nfs-version 3 --nfs-version 4
sudo rpc.mountd --debug all

#echo [+] Starting tinyproxy
#sudo tinyproxy
echo "[+] Setting up forwarded ports ${PORTFWD}"

IFS=',' read -ra PORTLIST <<< "${PORTFWD}"
for PORTPAIR in "${PORTLIST[@]}"
do
   SPORT=$(echo ${PORTPAIR} | cut -d':' -f1)
   DPORT=$(echo ${PORTPAIR} | cut -d':' -f2)
   echo "[+] mapping port ${SPORT} -> 192.168.100.2:${DPORT}"
   socat TCP-LISTEN:${SPORT},fork,reuseaddr TCP:192.168.100.2:${DPORT} &
done

echo '  ___ __  __ _   __  __'
echo ' / __|  \/  | | |\ \/ /   by Saumil Shah | The Exploit Laboratory'
echo ' | __| |\/| | |_| )  (    @therealsaumil | emux.exploitlab.net'
echo ' \___|_|  |__\___/_/\_\'
echo

exec "$@"
