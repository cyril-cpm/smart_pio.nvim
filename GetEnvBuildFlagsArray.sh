#!/bin/sh


platformio project config --json-output | jq --arg envName "env:$1" '.[$envName].build_flags'

