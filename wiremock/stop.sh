#!/bin/bash

port=7080

pidPort=`lsof -t -i :$port`

if [ ! -z "$pidPort" -a "$pidPort" != " " ]; then
  curl -X POST http://localhost:${port}/__admin/shutdown
  printf "\n%s%s\n" "----------- $(date '+%F %T,%3N') [STOP:$port] start"
  printf "\n%s\t%s\n" "PID:$pidPort" "Port: $port"
  kill $pidPort
  printf "\n%s%s\n\n" "----------- $(date '+%F %T,%3N') [STOP:$port] complete "
else
  printf "\n%s%s\n\n" "----------- $(date '+%F %T,%3N') [$port] not running "
fi
