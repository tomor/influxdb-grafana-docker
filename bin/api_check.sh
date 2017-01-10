#!/bin/bash
# Basic "ping" script for web services
# 2016-11-04

# start recurrently via: watch -c -n2 ./api_check.sh

# config - input file path with names and urls
source_file="./conf/services.list"

# config - on this order depends methods "curl_and_next" and "influx_push"
out_format="%{http_code} %{time_total} %{time_namelookup} %{time_connect} %{time_appconnect} %{time_pretransfer} %{time_redirect} %{time_starttransfer}\n"


function influx_push {
    IFS=' ' read -ra v <<< "$1"

    curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary \
         "http_response,host=${v[0]} http_code=${v[1]},time_total=${v[2]}"
}

function print_and_influx_push {
    echo "$1"
    influx_push "$1"
}

function check_config_file {
    if [ ! -f $source_file ];then
        echo "File $source_file does not exist. (see example $source_file.dist)"
        echo "Have you started this script from the project root dir?"
        exit 1
    fi
}


function curl_and_next {
    IFS=' ' read -ra ADDR <<< "$1"
    
    print_and_influx_push "`curl ${ADDR[1]} -L -o /dev/null -s -w "${ADDR[0]} $out_format"`"
}

function process_webservices {
    while read p; do
        curl_and_next "$p"
    done <$source_file
}


# main
check_config_file
process_webservices

