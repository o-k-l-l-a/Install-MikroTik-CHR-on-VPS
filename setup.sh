#!/bin/bash

set -e

# List versions available
VERSIONS=(
    "7.15.3" "2024-07-25"
    "7.15.2" "2024-06-28"
    "7.15.1" "2024-06-10"
    "7.15" "2024-05-30"
    "7.14.3" "2024-04-19"
    "7.14.2" "2024-03-27"
    "7.14.1" "2024-03-25"
    "7.14" "2024-03-25"
    "7.13.5" "2024-02-16"
    "7.13.4" "2024-02-07"
    "7.13.3" "2024-01-24"
    "7.13.2" "2024-01-12"
    "7.13.1" "2024-01-05"
    "7.13" "2023-12-14"
    "7.12.2" "2023-12-20"
    "7.12.1" "2023-11-17"
    "7.12" "2023-11-09"
    "7.11.3" "2023-09-27"
    "7.11.2" "2023-08-31"
    "7.11.1" "2023-08-30"
    "7.11" "2023-08-15"
    "7.10.2" "2023-07-12"
    "7.10.1" "2023-06-27"
    "7.10" "2023-06-15"
    "7.9.2" "2023-05-30"
    "7.9.1" "2023-05-19"
    "7.9" "2023-05-02"
    "7.8" "2023-02-24"
    "7.7" "2023-01-12"
    "7.6" "2022-10-17"
    "7.5" "2022-08-30"
    "7.4.1" "2022-08-04"
    "7.4" "2022-07-19"
    "7.3.1" "2022-06-09"
    "7.3" "2022-06-06"
    "7.2.3" "2022-05-02"
    "7.2.2" "2022-04-28"
    "7.2.1" "2022-04-06"
    "7.2" "2022-03-31"
    "7.1.5" "2022-03-22"
    "7.1.4" "2022-03-21"
    "7.1.3" "2022-02-11"
    "7.1.2" "2022-02-03"
    "7.1.1" "2021-12-21"
    "7.1" "2021-12-01"
    "6.49.15" "2024-04-25"
    "6.49.14" "2024-04-04"
    "6.49.12" "2024-01-22"
    "6.49.11" "2024-01-22"
)

# Display the list of versions to the user in two columns
VERSION_LIST=$(for ((i=0; i<${#VERSIONS[@]}; i+=2)); do echo "${VERSIONS[i]} ${VERSIONS[i+1]}"; done)
SELECTED_VERSION=$(whiptail --title "MikroTik Version Selection" --menu "Choose the version to download:" 20 60 10 ${VERSION_LIST} 3>&1 1>&2 2>&3)

# Check if the selected version is valid or not
if [[ -z "$SELECTED_VERSION" ]]; then
    echo "No version selected. Exiting."
    exit 1
fi

# Function to display progress
show_progress() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local temp

    echo -n " "
    while ps a | awk '{print $1}' | grep -q "$pid"; do
        temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    echo "    "
}

# Download the selected version
echo "Downloading MikroTik version $SELECTED_VERSION..."
wget -q https://download.mikrotik.com/routeros/$SELECTED_VERSION/chr-$SELECTED_VERSION.img.zip -O chr.img.zip &
show_progress $!

# Image extraction
echo "Extracting image..."
gunzip -c chr.img.zip > chr.img &
show_progress $!

# Mount the image
echo "Mounting image..."
mount -o loop,offset=33571840 chr.img /mnt &
show_progress $!

# Determining the main network interface and gateway
echo "Determining network interface and gateway..."
INTERFACE=$(ip route | grep default | awk '{print $5}')
ADDRESS=$(ip addr show $INTERFACE | grep global | cut -d' ' -f 6 | head -n 1)
GATEWAY=$(ip route list | grep default | cut -d' ' -f 3)

# Determine the main disk device
echo "Determining primary disk device..."
DISK_DEVICE=$(fdisk -l | grep "^Disk /dev" | grep -v "^Disk /dev/loop" | cut -d' ' -f 2 | tr -d ':')

# Create autorun script with MikroTik commands
echo "Creating autorun script..."
cat > /mnt/rw/autorun.scr <<EOF
/ip dns set servers=8.8.8.8
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set ssh disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes

/ip firewall filter add action=drop chain=input dst-port=53 in-interface=ether1 protocol=udp
/ip firewall filter add action=reject chain=input dst-port=53 in-interface=ether1 protocol=tcp reject-with=icmp-host-unreachable
/ip firewall filter add action=drop chain=input comment="drop winbox brute forcers" dst-port=8291 protocol=tcp src-address-list=Winbox_blacklist
/ip firewall filter add action=add-src-to-address-list address-list=Winbox_blacklist address-list-timeout=1w3d chain=input connection-state=new dst-port=8291 protocol=tcp src-address-list=Winbox_stage3
/ip firewall filter add action=add-src-to-address-list address-list=Winbox_stage3 address-list-timeout=1m chain=input connection-state=new dst-port=8291 protocol=tcp src-address-list=Winbox_stage2
/ip firewall filter add action=add-src-to-address-list address-list=Winbox_stage2 address-list-timeout=1m chain=input connection-state=new dst-port=8291 protocol=tcp src-address-list=Winbox_stage1
/ip firewall filter add action=add-src-to-address-list address-list=Winbox_stage1 address-list-timeout=1m chain=input connection-state=new dst-port=8291 protocol=tcp

/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATEWAY
EOF

# Unmount image
echo "Unmounting image..."
umount /mnt &
show_progress $!

# Trigger the kernel to empty caches
echo "Flushing kernel caches..."
echo u > /proc/sysrq-trigger

# Write the image to the main disk device
echo "Writing image to primary disk device..."
dd if=chr.img bs=1024 of=$DISK_DEVICE &
show_progress $!

# File system synchronization
echo "Syncing file system..."
echo s > /proc/sysrq-trigger &
show_progress $!

# restart
echo "Rebooting system..."
echo b > /proc/sysrq-trigger
