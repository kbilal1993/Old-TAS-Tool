#!/bin/bash
echo BB-UART1 > /sys/devices/platform/bone_capemgr/slots
stty 4800 < /dev/ttyO1
