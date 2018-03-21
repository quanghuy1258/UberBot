#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo 'UberBot: Introduction'
    echo '- List of information bot get: start_latitude, start_longitude, end_latitude, end_longitude, request_datetime, product_id, localized_display_name, distance, duration, low_estimate, high_estimate, currency_code'
    echo '- Syntax: '$0' <configuration file name>'
    echo '    Example: '$0' demo_configuration'
    echo '- Please modify "demo_configuration" file before using'
    echo '- To exit, please press Ctrl+C'
    exit
fi

SERVER_TOKEN=$(cat $1 | jq '.SERVER_TOKEN')
SERVER_TOKEN=${SERVER_TOKEN:1:-1}

output_file=$(cat $1 | jq '.output_file')
output_file=${output_file:1:-1}

sleep_in_seconds=$(cat $1 | jq '.sleep_in_seconds')

if ! [ -f $output_file ]; then
    echo "start_latitude","start_longitude","end_latitude","end_longitude","request_datetime","product_id","localized_display_name","distance,duration", "low_estimate","high_estimate,currency_code" >> $output_file
fi

while true; do
    cat $1 | jq -c '.target_routes[]' | while read i; do

        start_latitude=$(echo $i | jq '.start_latitude')
        start_longitude=$(echo $i | jq '.start_longitude')
        end_latitude=$(echo $i | jq '.end_latitude')
        end_longitude=$(echo $i | jq '.end_longitude')

        curl -H 'Authorization: Token '$SERVER_TOKEN \
             -H 'Accept-Language: en_US' \
             -H 'Content-Type: application/json' \
            'https://api.uber.com/v1.2/estimates/price?start_latitude='$start_latitude'&start_longitude='$start_longitude'&end_latitude='$end_latitude'&end_longitude='$end_longitude \
        | jq '.prices[]' \
        | jq --arg request_datetime "$(date -R)" '. + {start_latitude:'$start_latitude', start_longitude:'$start_longitude', start_longitude:'$start_longitude', end_latitude:'$end_latitude', end_longitude:'$end_longitude',request_datetime:$request_datetime}' \
        | jq ' [.start_latitude, .start_longitude, .end_latitude, .end_longitude, .request_datetime, .product_id, .localized_display_name, .distance, .duration, .low_estimate, .high_estimate, .currency_code] | @csv' \
        | jq -r '.' >> $output_file

    done
    sleep $sleep_in_seconds
done
