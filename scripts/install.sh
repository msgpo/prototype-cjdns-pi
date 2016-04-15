#!/bin/sh

# Shut down the wlan0 interface
sudo ifconfig wlan0 down

# Create mesh0 802.11s Mesh Point interface
sudo iw dev wlan0 interface add mesh0 type mp

# Bring up the mesh0 interface
sudo ifconfig mesh0 up

# Optionally assign IPv4 address to the mesh0 interface
# sudo ifconfig mesh0 192.168.X.Y

# Join the mesh network with radio in HT40+ htmode to enable 802.11n rates
sudo iw dev mesh0 mesh join tomesh freq 2412 HT40+

# Disable forwarding since we rely on cjdns to do routing and only uses Mesh Point as a point-to-point link
sudo iw dev mesh0 set mesh_param mesh_fwding=0

# Get tools
if ! [ "$(which git)" ] || ! [ "$(which nodejs)" ] || ! [ "$(which iperf3)" ]; then
	sudo apt-get update
	sudo apt-get install git nodejs iperf3
fi

# Get cjdns
if ! [ -d "cjdns" ]; then
	git clone https://github.com/hyperboria/cjdns.git
fi
cd cjdns

# Build cjdns with optimizations
if ! [ -x "cjdroute" ]; then
	./clean && NO_TEST=1 Seccomp_NO=1 CFLAGS="-s -static -Wall -mfpu=neon -mcpu=cortex-a7 -mtune=cortex-a7 -fomit-frame-pointer -marm" ./do
fi

# Generate cjdns node configurations
if ! [ -f "cjdroute.conf" ]; then
	./cjdroute --genconf > cjdroute.conf
fi

# Run cjdns
sudo ./cjdroute < cjdroute.conf