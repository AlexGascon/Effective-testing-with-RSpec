RSpec.configure do |c|
  c.before(:suite) do
    # Making sure that the DB has the currently used schema
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations')
    # Removing any possible leftover data
    DB[:expenses].truncate
  end
end