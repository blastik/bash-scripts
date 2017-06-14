#!/bin/sh

maquinas=servers.txt
dirs=`cat directorios.txt`

while read -r server; do
echo "$server"
ssh -T root@"$server" << EOSSH
    for i in "$dirs"; do
    echo "eliminando logs de más de 1 año en \$i"
	find \$i -type f \( -name \*.log -o -name \*.gz \)  -mtime +365 -exec rm {} \;
    done
EOSSH
done < $maquinas
