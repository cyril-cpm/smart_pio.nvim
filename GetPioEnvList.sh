#!/bin/sh

platformio project config --json-output | jq 'keys | .[] | scan("(env:)(\\w*)") | .[1]'
