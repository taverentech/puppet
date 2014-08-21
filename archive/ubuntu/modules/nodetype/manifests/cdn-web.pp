#######################################################
# CDN origin web server

class cdn-web {
  notice(">>> cdn-web class <<<")
  # Include full game web server stack
  include nginx
  include php
  include php-fpm

  if ($::environment == "dev") {

  } elsif ($::environment == "test") {

  } elsif ($::environment == "stage") {

  } elsif ($::environment == "prod") {
     realize (
     Users::Functions::Localuser["excdn"],
     )

  } # end of which environment

}
