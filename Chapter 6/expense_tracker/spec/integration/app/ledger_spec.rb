require_relative '../../../app/ledger'
require_relative '../../../config/sequel'

module ExpenseTracker
  RSpec.describe Ledger, :aggregate_failures, :db do
    let(:ledger) { Ledger.new }
    let(:expense) do
      {
        'payee' => 'Starbucks',
        'amount' => '5.75',
        'date' => '2017-06-10'
      }
    end

    describe '#record' do
      context 'with a valid expense' do
        it 'successfully saves the expense in the DB' do
          result = ledger.record(expense)

          # In pure TDD, we would include only one `expect` per test. However, as
          # tests that interact with the DB are quite slow, we're going to tradeoff
          # some "pureness" for speed.
          expect(result).to be_success
          expect(DB[:expenses].all).to match [a_hash_including(
                                                 id: result.expense_id,
                                                 payee: 'Starbucks',
                                                 amount: 5.75,
                                                 date: Date.iso8601('2017-06-10')
                                             )]
        end

        it 'when the expense lacks a payee' do
          expense.delete('payee')

          result = ledger.record(expense)

          expect(result).not_to be_success
          expect(result.id).to eq(nil)
          expect(result.expense_id).to eq(nil)
          expect(result.error_message).to include ('`payee` is required')

          expect(DB[:expenses].count).to eq(0)
        end
      end

    end
  end
end