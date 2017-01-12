#!/bin/bash
# Basic "ping" script for web services
# 2016-11-04

# start recurrently via: watch -c -n2 ./api_check.sh
 
# config - input file path with names and urls
SOURCE_FILE="./conf/services.list"
SOURCE_FILE_SEP="|"

# config - on this order depends methods "curl_and_next" and "influx_push"
OUT_FORMAT="%{http_code} %{time_total} %{time_namelookup} %{time_connect} %{time_appconnect} %{time_pretransfer} %{time_redirect} %{time_starttransfer}\n"


function influx_push {
    IFS=' ' read -ra v <<< "$1"
    
    curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary \
         "http_responses,host=${v[0]} http_code=${v[1]},time_total=${v[2]},time_namelookup=${v[3]},time_connect=${v[4]},time_appconnect=${v[5]},time_pretransfer=${v[6]},time_redirect=${v[7]},time_settransfer=${v[8]}"
}

function print_and_influx_push {
    echo "$1"
    influx_push "$1"
}

function check_config_file {
    if [ ! -f $SOURCE_FILE ];then
        echo "File $SOURCE_FILE does not exist. (see example $SOURCE_FILE.dist)"
        echo "Have you started this script from the project root dir?"
        exit 1
    fi
}

function curl_and_next {
    IFS=$SOURCE_FILE_SEP read -ra ADDR <<< "$1"
    
    print_and_influx_push "`curl ${ADDR[1]} -m 30 -L -o /dev/null -s -w "${ADDR[0]} $OUT_FORMAT"`"
}

function process_webservices {
    while read p; do
        curl_and_next "$p"
    done <$SOURCE_FILE
}


# main
check_config_file
process_webservices

