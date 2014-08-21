# NOTE: whenever you add user here, you must exclude in 
#	generate_entitlements.pl for both shell and sudo_all
class users::default {
  realize (
    Users::Functions::Localuser["exservices"],
    Users::Functions::Localuser["tunnel"],
  )

  if ($::lsbdistcodename == "precise") {
    realize (
      Users::Functions::Localuser["ubuntu"],
      Users::Functions::Localuser["backuppc"],
    )
    groups::functions::adduser { sudo_ubuntu: unique => "default", gname  => "sudo", uname  => "ubuntu", }
    groups::functions::adduser { sudo_backuppc: unique => "default", gname  => "sudo", uname  => "backuppc", }
  }
  realize (
    Users::Functions::Localuser["agreengrass"],
    Users::Functions::Localuser["jtodd"],
    Users::Functions::Localuser["jlegate"],
    Users::Functions::Localuser["mponce"],
    Users::Functions::Localuser["nicka"],
    Users::Functions::Localuser["alex"],
    Users::Functions::Localuser["danielle"],
    Users::Functions::Localuser["gerry"],
    Users::Functions::Localuser["badams"],
    Users::Functions::Localuser["tcarpenter"],
    Users::Functions::Localuser["jsasser"],
  )
  groups::functions::adduser { sudo_agreengrass: unique => "default", gname  => "sudo", uname  => "agreengrass", }
  groups::functions::adduser { sudo_jtodd: unique => "default", gname => "sudo", uname => 'jtodd', }
  groups::functions::adduser { sudo_jlegate: unique => "default", gname => "sudo", uname => 'jlegate', }
  groups::functions::adduser { sudo_mponce: unique => "default", gname => "sudo", uname => 'mponce', }
  groups::functions::adduser { sudo_nicka: unique => "default", gname => "sudo", uname => 'nicka', }
  groups::functions::adduser { sudo_alex: unique => "default", gname => "sudo", uname => 'alex', }
  groups::functions::adduser { sudo_danielle: unique => "default", gname => "sudo", uname => 'danielle', }
  groups::functions::adduser { sudo_badams: unique => "default", gname => "sudo", uname => 'badams', }
  groups::functions::adduser { sudo_tcarpenter: unique => "default", gname => "sudo", uname => 'tcarpenter', }
  groups::functions::adduser { sudo_jsasser: unique => "default", gname => "sudo", uname => 'jsasser', }

  if ($::domain == "sjc2.example.com") {
    realize (
      Users::Functions::Localuser["kvellman"],
    )
    groups::functions::adduser { sudo_kvellman: unique => "default", gname => "sudo", uname => 'kvellman', }
  }
}
