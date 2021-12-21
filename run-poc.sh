#! /usr/bin/env bash
shopt -s expand_aliases

if [ "$1" == "" ] || [ $# -gt 1 ];
then
        echo "pass IP address of machine you are running this from"
        exit 1
fi


if command -v podman &> /dev/null
then
    echo "podman found..."
    alias docker="podman"
fi

docker kill $(docker ps -q)
docker build -t webserver:latest -f ./vulnerable-application/Dockerfile ./vulnerable-application/.
docker build -t exploit-ldap-server:latest -f ./exploit-ldap-server/Dockerfile ./exploit-ldap-server/.

docker run --name webserver --rm -d -p 8080:8080 webserver
docker run  --name ldap-exploit-server --rm -d -p 8000:8000 -p 1389:1389 exploit-ldap-server $1