################################################################
#(@) Joe DeCello, 2012
################################################################

# Example module - used for testing masterless wrapper

class example (
  param1 = 1,
  param2 = 2,
  expath = '/tmp',
{
  notice(">>> example class <<<")
  notify{"Loading example class": }
  tag("example")

  ##FILES
  file { 'example_file':
    path   => "$expath/example",
    sourc  => "puppet:///modules/example/example",
    backup => ".$::timestamp",
  }

  exec { "install_example_default_enable":
    command => 'sed -i "s/^startup=0$/startup=1/" /etc/default/example',
    onlyif => 'grep -c ^startup=0$ /etc/default/example',
  }

#######################################################
