
#!/bin/bash
HOSTNAME=$(hostname)

# Ensure the script is run as root
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root."
  exit 1
fi

echo "Starting system cleanup..."

# Update package lists
echo "Updating package lists..."
apt-get update

# Remove unused packages and dependencies
echo "Removing unused packages and dependencies..."
apt-get autoremove -y
apt-get autoclean -y

# Clean package cache
echo "Cleaning package cache..."
apt-get clean

# Remove orphaned packages
echo "Removing orphaned packages..."
apt-get install -y deborphan
deborphan | xargs apt-get -y remove --purge

# Remove old kernels
echo "Removing old kernels..."
current_kernel=$(uname -r)
dpkg -l 'linux-*' | sed '/^ii/!d;/linux-image/!d;/'"$current_kernel"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge

# Clean up apt cache
echo "Cleaning apt cache..."
apt-get autoremove -y
apt-get clean

# Clean up temporary files
echo "Cleaning temporary files..."
rm -rf /tmp/*
rm -rf /var/tmp/*

# Clean systemd journal logs
echo "Cleaning systemd journal logs..."
journalctl --vacuum-time=2weeks

# Remove old log files
echo "Removing old log files..."
find /var/log -type f -name "*.gz" -exec rm -f {} \;
find /var/log -type f -name "*.1" -exec rm -f {} \;
find /var/log -type f -name "*.old" -exec rm -f {} \;

# Clear bash history
echo "Clearing bash history..."
cat /dev/null > ~/.bash_history
history -c

echo "System cleanup completed successfully."

bash /ntfy.sh "Server $HOSTNAME cleanup script ran" "default"