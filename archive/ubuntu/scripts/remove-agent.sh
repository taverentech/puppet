#!/bin/bash

CLIENT=$1

if [ -z "$1" ]; then
    echo "Usage: $0 fqdn (of host to remove from puppetmaster)" 1>&2
fi
if [[ "$1" == puppet* ]]; then
    echo "Usage: $0 fqdn [Not for removal of puppet* !]" 1>&2
    exit 1
fi

echo "removing certs"
puppet cert clean ${CLIENT}

echo "removing reports"
rm -rf /var/lib/puppet/reports/${CLIENT}
rm -f /var/lib/puppet/yaml/node/${CLIENT}.yaml
rm -f /var/lib/puppet/yaml/facts/${CLIENT}.yaml

echo "Done removing ${CLIENT} from `facter fqdn`"
