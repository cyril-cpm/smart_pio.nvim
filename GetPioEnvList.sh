#!/bin/sh

platformio project config --json-output | jq 'keys | .[] | scan("(env:)(\\w*)") | .[1]' | grep -o -e "\\w*"
