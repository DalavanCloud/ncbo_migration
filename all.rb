# Require migrations in the order they need to run
# For example, ontologies requires users, categories, and groups
require_relative 'users'
require_relative 'categories'
require_relative 'groups'
require_relative 'ontologies'
# TODO: add projects and reviews
#require_relative 'projects'
#require_relative 'reviews'

