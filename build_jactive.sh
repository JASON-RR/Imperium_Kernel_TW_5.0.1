#!/bin/sh
export BOARD="jactive"
export CARRIER="eur"
export ADD_KTWEAKER="Y"
export EXEC_LOKI="N"
export RD_CMDLINE="console=null androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 maxcpus=4"
export MREV="KK4.4"
export VERSION=4.4
./build_master.sh
