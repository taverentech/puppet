################################################################
#(@) Joe DeCello, 2012
################################################################

# Example module - used for testing masterless wrapper

class example (
  $param1 = 1,
  $param2 = 2,
  $expath = '/tmp',
) {
  notice(">>> example class <<<")
  notify{"Loading example class": }
  tag("example")

  ##FILES
  file { 'example_file':
    ensure  => present,
    path   => "$expath/example_file",
    source => "puppet:///modules/example/example",
    mode    => '0644',
    backup => ".$::timestamp",
  }

  file { 'example_template':
    ensure  => present,
    path   => "$expath/example_template",
    content => template('example/example.erb'),
    mode    => '0644',
    backup => ".$::timestamp",
  }

  exec { "install_example_file_via_exec":
    command => 'echo "example" > /tmp/example_exec',
    unless => 'grep -c ^example /tmp/example_exec',
  }

} # end of class
#######################################################
