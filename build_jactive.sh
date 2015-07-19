#!/bin/sh
export BOARD="jactive"
export CARRIER="eur"
export ADD_STWEAKS="Y"
export RD_CMDLINE="console=null androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 maxcpus=4"
./build_master.sh
