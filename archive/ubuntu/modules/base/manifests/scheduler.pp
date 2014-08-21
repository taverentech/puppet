################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class base::scheduler {
  notify{"scheduler.pp": }
  notice(">>> base::scheduler class <<<")

  $devices = split($::blockdevices,",")
  conf { $devices:; }
  define conf {
    $scheduler = "deadline"
    $device = $name
    notify { "set $device scheduler to $scheduler":; }
    exec { "echo $scheduler > /sys/block/$device/queue/scheduler":
      onlyif => "ls /sys/block/$device/queue/scheduler && fgrep -c -v [$scheduler] /sys/block/$device/queue/scheduler",
    }
  }

}
