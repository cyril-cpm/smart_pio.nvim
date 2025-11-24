#!/bin/bash

jq '[.[].command | scan("-I\\. src\\/\\w*\\.cpp") | scan("\\w*\\.cpp")] | sort' compile_commands.json
