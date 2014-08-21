#######################################################
# CDN LB Proxy Servers

class cdn-lb {
  notice(">>> wc-fb-lb class <<<")

  if ($::environment == "dev") {

  } elsif ($::environment == "test") {

  } elsif ($::environment == "stage") {

    include haproxy

  } elsif ($::environment == "prod") {

    include haproxy

  }

}
