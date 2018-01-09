#!/bin/bash

## This nonsense brought to you by
# https://github.com/ossec/ossec-hids/issues/1026

/var/ossec/bin/ossec-remoted &
exec tail -f /var/ossec/logs/ossec.log
