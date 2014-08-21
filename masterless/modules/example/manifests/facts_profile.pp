################################################################
#(@) Joe DeCello, 2012
################################################################

class example::facts_profile {

  notify{"DEBUG: Loading class example::facts_profile": }

  # Copy down entire source directory
  file { 'facterdir':
    path    => '/var/lib/puppet/lib/facter',
    source  => 'puppet:///modules/example/facter/',
    ensure  => directory,
    recurse => true,
    mode    => '0644',
  }

} # end of class
