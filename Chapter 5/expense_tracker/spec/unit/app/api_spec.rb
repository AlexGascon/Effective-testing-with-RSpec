require 'rspec'
require_relative '../../../app/api'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    # We won't define Ledger yet, as currently what we want to test is the API
    # Instead, we'll mock its behaviour.
    let(:ledger){ instance_double('ExpenseTracker::Ledger') }

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        # We don't need real data because we're mocking the behaviour
        let(:expense){ {'some' => 'data'} }

        before do
          # Mocking Ledger's behaviour
          allow(ledger).to receive(:record)
                               .with(expense)
                               .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        let(:expense){ {'some' => 'data'} }

        before do
          # Mocking Ledger's behaviour
          allow(ledger).to receive(:record)
                               .with(expense)
                               .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(422)
        end
      end
    end
  end
end
