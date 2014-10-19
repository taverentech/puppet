##############################################################################
#(@) Joe DeCello, 2014
##############################################################################
# 2013 - derived directly from bash script I wrote to setup hadoop datanodes
# 2014 - updated for hiera
#Partition and format disks only if not already a filesystem
#
# WARNING - THIS MODULE MAY DESTROY DATA - use knowingly
#
#  Use hiera-able parameter for list of datadir block devices
class setup_jbod (
  $datadevices='sdX,sdY,sdZ',
  $debug=true,
) {

  if ( $debug ) {
    notify{'DEBUG: Loading class setup_datafs': }
  }

  #Create array from string list with commas
  $devices = split($datadevices,',')

  #call function for each element of the arrray
  conf { $devices: ; }

  #Define a resource called conf aka classname::conf that is called above
  define conf {

    $mydevice=$name
    if ( $debug ) {
      notify{"WARNING: Might be destroying data on /dev/${mydevice}": }
    }
    exec { "format_${mydevice}1":
      command => "dd if=/dev/zero of=/dev/${mydevice} bs=1024 count=10 && parted --align optimal /dev/${mydevice} 'mklabel gpt' && parted --align optimal /dev/${mydevice} 'mkpart primary 1 -1' && parted --align optimal /dev/${mydevice} 'align-check optimal 1' && mkfs.ext4 -F -m 0 -L /dev/${mydevice}1 /dev/${mydevice}1",
      unless  => [
        "df | grep ${mydevice}1","file -Ls /dev/${mydevice}1 | grep filesystem"
      ],
      timeout => 7200, # 2hr timeout, default is 5m
    }

  } # end of define

}
