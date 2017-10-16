require 'sinatra/base'
require 'json'

module ExpenseTracker
	class API < Sinatra::Base
		def initialize(ledger: Ledger.new)
			@ledger = ledger
			super()
		end

		post '/expenses' do
      # Parsing the expense from the request body
			expense = JSON.parse(request.body.read)
      # Using the Ledger to record the expense
      result = @ledger.record(expense)
      # Returning a JSON document containing the result expense ID
      JSON.generate('expense_id' => result.expense_id)
		end

		get '/expenses/:date' do
			JSON.generate([])
		end
	end
end