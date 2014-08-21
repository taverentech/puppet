################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

# TODO do all valid block devices
class scheduler {
  tag("safe")
  notify{"class scheduler": }

  notice(">>> scheduler class <<<")

  exec { "echo deadline > /sys/block/sda/queue/scheduler":
    onlyif => "ls /sys/block/sda/queue/scheduler && fgrep -c -v [deadline] /sys/block/sda/queue/scheduler",
  }
  exec { "echo deadline > /sys/block/sdb/queue/scheduler":
    onlyif => "ls /sys/block/sdb/queue/scheduler && fgrep -c -v [deadline] /sys/block/sdb/queue/scheduler",
  }
  exec { "echo deadline > /sys/block/sdc/queue/scheduler":
    onlyif => "ls /sys/block/sdc/queue/scheduler && fgrep -c -v [deadline] /sys/block/sdc/queue/scheduler",
  }
  exec { "echo deadline > /sys/block/sdd/queue/scheduler":
    onlyif => "ls /sys/block/sdd/queue/scheduler && fgrep -c -v [deadline] /sys/block/sdd/queue/scheduler",
  }
  exec { "echo deadline > /sys/block/xvda/queue/scheduler":
    onlyif => "ls /sys/block/xvda/queue/scheduler && fgrep -c -v [deadline] /sys/block/xvda/queue/scheduler",
  }
  exec { "echo deadline > /sys/block/xvdb/queue/scheduler":
    onlyif => "ls /sys/block/xvdb/queue/scheduler && fgrep -c -v [deadline] /sys/block/xvdb/queue/scheduler",
  }

}
