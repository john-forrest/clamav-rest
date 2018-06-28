#!/bin/bash

export HOST=${HOST:-http://localhost:8080}

testTesti() {
    /testi.sh
    assertEquals 0 $?
}

testScan() {
    fo=$(curl -s -F "name=blabla" -F "file=@./testi.sh" ${HOST}/scan)
    res=$?
    assertEquals 'Everything ok : true' "$fo"
    assertEquals 0 $res
}

testJscan() {
    fo=$(curl -s -F "name=blabla" -F "file=@./testi.sh" ${HOST}/jscan)
    res=$?
    assertEquals '{"reply":true,"raw":"stream: OK"}' "$fo"
    assertEquals 0 $res
}

testRscan() {
    fo=$(curl -s -F "name=blabla" -F "file=@./testi.sh" ${HOST}/rscan)
    res=$?
    assertEquals 'stream: OK' "$fo"
    assertEquals 0 $res
}

# wait for test of the system to start before we actually try and use it
sleep 45

. $(which shunit2)

