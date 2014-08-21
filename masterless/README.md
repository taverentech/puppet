################################################################
#(@) Joe DeCello, 2012
################################################################

There are two very clear use cases for this wrapper script:
1. You want to test your puppet code from ./ without publishing to master
2. You do not use puppetmasters and need to run your code from ./ normally

This is the basic framework for running puppet masterless.   There is nothing
really complicated here.  Basically you can run puppet apply with a bunch of
options such that ./ is your puppetmaster with ZERO code changes to your 
manifests.   Just run puppet using the wrapper script.   

Requirements, following the diretory structure here, you simple need:
./scripts/masterless-wrapper.sh
./scripts/fileserver.conf

The fileserver.conf simply makes ./ the provider for puppet:/// in your source
and template defitions.   It works beautifully and I have used this for years
for testing my code and more recently for running masterless via cron.

If you do NOT use hiera, shoot yourself and remove this line from wrapper:
 --hiera_config=./hiera/hiera-local.yaml \
Note, you cannot just comment it out unless you move it below the EOF line.
If you have a brain and are using hiera, just need to make sure that line
points at your hiera config.   The only diff between puppetmaser and master-
less is that :datadir: ./hiera, may be different.

NOTE: --pluginsync will not work.   You will need to copy facter files to 
/var/lib/puppet/lib/facter  (see modules/example/manifests/facts_profile.pp)

Usage

cd /directory/to/puppet/stuff
./scripts/masterless-wrapper.sh CLASSNAME {option}

Examples

./scripts/masterless-wrapper.sh example {option}
