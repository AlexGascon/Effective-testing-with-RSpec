require 'sinatra/base'
require 'json'
require 'ox'
require_relative 'ledger'
require 'pry'

module ExpenseTracker
	class API < Sinatra::Base
		def initialize(ledger: Ledger.new)
			@ledger = ledger
			super()
		end

		def parse_expense(request)
			case request.media_type
				when 'text/xml'
					nil
				when 'application/json', 'application/x-www-form-urlencoded', ''
					JSON.parse(request.body.read)
				else
					nil
			end
		end

		post '/expenses' do
      expense = parse_expense(request)
      result = @ledger.record(expense)

      if result.success?
        JSON.generate('expense_id' => result.expense_id)
      else
        status 422
        JSON.generate('error' => result.error_message)
      end
		end

		get '/expenses/:date' do
			JSON.generate(@ledger.expenses_on(params[:date]))
		end
	end
end