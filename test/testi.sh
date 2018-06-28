#!/bin/bash

echo "testing by scanning this file.."

HOST=${HOST:=http://localhost:8080}

fo=$(curl -s -F "name=blabla" -F "file=@./testi.sh" ${HOST}/scan)

if [ "$fo" != "Everything ok : true" ]
  then
    echo "not ok.. $fo"
    exit -1
fi
