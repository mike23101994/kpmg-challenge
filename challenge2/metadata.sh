#!/bin/bash

METADATA=$(curl -s http://169.254.169.254/latest/meta-data/)
JSON="{"
for field in $METADATA
do
  value=$(curl -s http://169.254.169.254/latest/meta-data/$field)
  JSON="$JSON \"$field\": \"$value\","
done
JSON=${JSON%,}"}"
if [ $# -eq 1 ]; then
  VALUE=$(echo $JSON | jq -r --arg key "$1" '.[$key]')
  echo $VALUE
else
  echo $JSON
fi



