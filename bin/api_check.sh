#!/bin/bash
# Basic "ping" script for web services
# 2016-11-04

# start recurrently via: watch -c -n2 ./api_check.sh

function influx_push {
    local res="$1"
     
    service_name=`echo $res | awk -F'|' '{ print $1 }' | tr -d ' '`
    http_code=`echo $res | awk -F'|' '{ print $2 }' | tr -d ' '`
    time_total=`echo $res | awk -F'|' '{ print $3 }' | tr -d ' '`

    curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary "http_services_response,host=${service_name} http_code=${http_code},time_total=${time_total}"
}

function print_and_influx {
    local res="$1"

    echo "$res"
    echo "$out_row"
    influx_push "$res"
}

out_head="   SERVICE NAME        | CODE | TIME   |"
out_row="----------------------------------------"
echo "$out_row"
echo "$out_head"
out_format="%{http_code}  | %{time_total}  |\n"


# Ping the services
echo $out_row
print_and_influx "`curl https://google.com -L -o /dev/null -s -w "Google.com            | $out_format"`"
echo $out_row
print_and_influx "`curl https://seznam.cz  -L -o /dev/null -s -w "Seznam.cz             | $out_format"`"
echo $out_row


# Full format:
#out_format="\"%{http_code}\"  | \"%{time_total}\" |  | \"%{time_namelookup}\"  | \"%{time_connect}\"   | \"%{time_appconnect}\"      | \"%{time_pretransfer}\"       | \"%{time_redirect}\"    | \"%{time_starttransfer}\"         |\n\""
#out_head="   SERVICE NAME        | CODE | TIME  |  | LOOKUP | CONNECT | APPCONNECT | PRETRANSFER | REDIRECT | STARTTRANSFER |"
# Example output (old format):
# SERVICE NAME           | TIME LOOKUP | TIME CONNECT | TIME APPCONNECT | TIME PRETRANSFER | TIME REDIRECT | TIME STARTTRANSFER | TIME TOTAL
# ------------------------------------------------------------------------------------------------------------------------------------------
# service 1              | 0.004       | 0.004        | 0.000           | 0.004            | 0.000         | 0.582              | 0.582

