#!/bin/bash
# Basic "ping" script for web services
# 2016-11-04

# Note about color output and locale: If colors doesn't work, then it might be because of locale settings on the machine.
# This scripts needs curl to return times in this type format "0.343".(e.g. en_US.UTF-8) 
# When it returns the float number with comma "0,045" then the awk comparsion doesn't identify this as  
# float and  comparsion doesn't work.  Use command "locale" to check locale settings on the PC

# start recurrently via: watch -c -n2 ./api_check.sh

#set -x # activate debugging from here

# Function for printing colorfull curl result
# It checks the response code and the time and make it colorful 
# - if the code is not 200 or the time is too hight
#
# @param string Result of curl which looks like: "- ACCEPTANCE          | 200  | 1.188  |"
# @return void  It echoes the incomming curl result
function print_color {
    local res="$1"
    
    # colorize is set to 1 when time is bigger then specified number 
    code_fail=`echo $res | awk -F'|' '{ if ($2 != 200) { print "1" } else { print "0" } }'`
    time_err=`echo $res | awk -F'|' '{ if ($3 > 3) { print "1" } else { print "0" } }'`
    time_warn=`echo $res | awk -F'|' '{ if ($3 > 1.1) { print "1" } else { print "0" } }'`

    if [ "$code_fail" -eq "1" ]; then
      echo "$(tput setaf 1)$(tput rev)$res$(tput sgr 0)"
    elif [ "$time_err" -eq "1" ]; then
      echo "$(tput setaf 3)$(tput rev)$res$(tput sgr 0)"
    elif [ "$time_warn" -eq "1" ]; then
      echo "$(tput setaf 3)$res$(tput sgr 0)"
    else
      echo "$res"
    fi
}

function influx_push {
    local res="$1"
     
    service_name=`echo $res | awk -F'|' '{ print $1 }' | tr -d ' '`
    http_code=`echo $res | awk -F'|' '{ print $2 }' | tr -d ' '`
    time_total=`echo $res | awk -F'|' '{ print $3 }' | tr -d ' '`

#    echo $time_total
curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary "http_services_response,host=${service_name} http_code=${http_code},time_total=${time_total}"
}

function print_and_influx {
    local res="$1"

    print_color "$res"
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

