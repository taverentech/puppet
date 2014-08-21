#!/bin/bash
PUPDIR="/path/to/your/puppet/stuff"
CLASS=$1
OPTIONS=$2
if [ -z $CLASS ]; then
  echo "Usage: $0 classname"
  exit 1
fi
if [ ! -d $PUPDIR ]; then
  echo "FATAL: $0 could not cd to puppet dir $PUBDIR"
  exit 1
fi
cd $PUDIR || exit 1
# Enable agent and remove lockfile
puppet agent --enable
# Run agent puppetmasterless
puppet apply -v $OPTIONS \
 --modulepath=./modules \
 --factpath=./modules/base/lib/facter \
 --fileserverconfig=./scripts/fileserver.conf \
 --hiera_config=./hiera/hiera-local.yaml \
<<EOF
Exec {
  path => [
    "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/",
    "/usr/local/bin/", "/usr/local/sbin/",
  ]
}
notice(">>> host_environment is $::host_environment <<<")
notice(">>> fqdn is $::fqdn <<<")
notice(">>> is_virtual is $::is_virtual <<<")
notice(">>> osfamily is $::osfamily <<<")
notice(">>> operatingsystem is $::operatingsystem <<<")
notice(">>> operatingsystemrelease is $::operatingsystemrelease <<<")
include ${CLASS}
EOF
