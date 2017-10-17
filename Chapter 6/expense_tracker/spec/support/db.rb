RSpec.configure do |c|
  c.before(:suite) do
    # Making sure that the DB has the currently used schema
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations')
    # Removing any possible leftover data
    DB[:expenses].truncate
  end

  # For each example marked as requiring the DB (that means the :db tag)
  c.around(:example, :db) do |example|
    DB.transaction(rollback: :always){ example.run }
  end
end