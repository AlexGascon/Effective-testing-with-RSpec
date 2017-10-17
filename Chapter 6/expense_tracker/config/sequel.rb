require 'sequel'

# We want to use different databases for testing, development and production
# This will ensure that we don't overwrite our real data during testing
DB = Sequel.sqlite("./db/#{ENV.fetch('RACK_ENV', 'development')}.db")