# Managed by Puppet
/var/log/puppet/puppetd.*log {
  missingok
  create 0644 puppet puppet
  compress
  rotate 4
  
  postrotate
    [ -e /etc/init.d/puppet ] && /etc/init.d/puppet reload > /dev/null 2>&1 || true
  endscript
}
