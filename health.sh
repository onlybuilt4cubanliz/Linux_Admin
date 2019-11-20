#!/bin/bash

echo "Network Health Information"

echo "Memory Information"
  cat /proc/meminfo
echo " Running Processes"
  ps
echo "Network Status"
  uptime
  Topdump

echo "Subsystem Information"
  iostat

echo "Network Health Report Done"
