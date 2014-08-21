# Main puppet recipe
# site.pp

notice (">>> site.pp <<<")

# classes of recipes, broken down by package
import "templates"

# List of puppet clients to manage
import "nodes"
