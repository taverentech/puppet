# Managed by Puppet

# Set path
PATH=/usr/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin

# Run once per day to scan hw with facter and upload to CMDB
11 06 * * * root /usr/local/bin/hwscan.sh > /dev/null 2>&1
