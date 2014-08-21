#!/bin/bash
CLASS=$1
if [ -z $CLASS ]; then
  echo "Usage: $0 classname"
  exit 1
fi
# --execute "include $1" \
sudo puppet apply -v \
 --modulepath=./modules \
 --factpath=./modules/base/lib/facter \
 --fileserverconfig=./scripts/fileserver.conf \
<<EOF
Exec {
  path => [
    "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/",
    "/usr/local/bin/", "/usr/local/sbin/",
  ]
}
notice(">>> fqdn is $::fqdn <<<")
notice(">>> domain is $::domain <<<")
notice(">>> cluster is $::cluster <<<")
notice(">>> lsbdistcodename is $::lsbdistcodename <<<")
include ${CLASS}
EOF
