# Main puppet recipe
# site.pp

notice (">>> site.pp <<<")

#hiera_include('classes')

# classes of recipes, broken down by package
import "templates"

# List of puppet clients to manage
import "nodes"
