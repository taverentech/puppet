################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class verify {
  notify{"class verify": }
  # prints on puppetmaster
  notice(">>> verify class <<<")
  # prints on puppet agent (client)
  notify{"OK: Puppetmaster Response Success": }
  tag("verify")

}
