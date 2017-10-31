require 'rspec'
require_relative '../../../app/api'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    def response
      JSON.parse(last_response.body)
    end

    # We won't define Ledger yet, as currently what we want to test is the API
    # Instead, we'll mock its behaviour.
    let(:ledger){ instance_double('ExpenseTracker::Ledger') }

    describe 'POST /expenses' do
      # We don't need real data because we're mocking the behaviour
      let(:expense){ {'some' => 'data'} }

      context 'when the expense is successfully recorded' do

        before do
          # Mocking Ledger's behaviour
          allow(ledger).to receive(:record)
                               .with(expense)
                               .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)

          expect(response).to include('expense_id' => 417)
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

          expect(response).to include('error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(422)
        end
      end

      context 'input data format' do

        before do
          # Mocking Ledger's behaviour
          # We don't want to test ledger, but the data formats
          allow(ledger).to receive(:record)
                               .with(expense)
                               .and_return(RecordResult.new(true, 417, nil))
        end

        it 'is JSON by default' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(200)
        end

        it 'is JSON if we set Content-Type header to application/json' do
          post '/expenses', JSON.generate(expense)  do
            header['Content-Type'] = 'application/json'
          end

          expect(last_response.status).to eq(200)
        end

        it 'is XML if we set Content-Type header to text/xml' do
          post '/expenses'do
            header['Content-Type'] = 'text/xml'
          end

          expect(last_response.status).to eq(200)
        end

        it 'generates an error if the requested type isn\'t JSON or XML' do
          post '/expenses', JSON.generate(expense)  do
            header['Content-Type'] = 'random/content_type'
          end

          expect(last_response.status).to eq(415)
        end
      end
    end

    describe 'GET /expenses/:date' do
      let(:date){ '2017-06-12' }

      context 'when expenses exist on the given date' do
        let(:expenses_on_date){ JSON.generate([{'some' => 'data'}])}

        before do
          allow(ledger).to receive(:expenses_on)
                               .with(date)
                               .and_return(expenses_on_date)
        end

        it 'returns the expense records as JSON' do
          get "/expenses/#{date}"

          expect(response).to eq(JSON.generate([{'some' => 'data'}]))
        end

        it 'responds with a 200 (OK)' do
          get "/expenses/#{date}"

          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
                               .with(date)
                               .and_return(JSON.generate([]))
        end

        it 'returns an empty array as JSON' do
          get "/expenses/#{date}"

          expect(response).to eq(JSON.generate([]))
        end

        it 'responds with a 200 (OK)' do
          get "/expenses/#{date}"

          expect(last_response.status).to eq(200)
        end
      end

      context 'output data format' do
        it 'is JSON by default'

        it 'is JSON if we set Accept header to application/json'

        it 'is XML if we set Accept header to text/xml'
      end
    end
  end
end
