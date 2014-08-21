#######################################################
# Support All (web and db stack)

class support-all {
  notice(">>> support-all class <<<")

  include support-web
  if ($::environment == "dev") {
  }

}
