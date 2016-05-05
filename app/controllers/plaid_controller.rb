class PlaidController < ApplicationController
  def create
    user = Plaid.add_user(
      'connect',
      params[:username],
      params[:password],
      params[:type],
      params[:pin],
      params[:options]
    )
    user.transactions = []
    render json: user
  rescue Plaid::RequestFailed => e
    render json: { errors: [e.message] }, status: 403
  end

  def mfa
    
  end

  def get_transactions
    response = Plaid.transactions(params[:access_token], options = params[:options] || {})
    # binding.pry
    # transactions = []
    # response.transactions.each do |trans|
    #   transactions << {
    #     account: trans.account,
    #     amount: trans.amount,
    #     post_date: trans.date,
    #     plaid_id: trans.id,
    #     detail: trans.name
    #   }
    # end
    render json: response
  end

  def search
    query_params = params.slice(:q, :id).merge(p: 'connect')
    institutions = Plaid.search_institutions(query_params)
    institutions = [institutions] unless institutions.is_a?(Array)
    institutions.each do |institution|
      institution[:logo] = nil # TODO this is just to make the json data more human readable. Maybe remove this later.
    end
    render json: institutions
  end

  def all_institutions
    list = []
  end
end
