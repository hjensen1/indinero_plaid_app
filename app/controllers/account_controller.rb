class AccountController < ApplicationController
  before_action :set_user

  def submit_credentials
    if params[:access_token].present?
      update_user
    else
      create_user
    end
    render json: user_hash
  rescue => e
    render json: { errors: [e.message] }, status: 403
  end

  def institution_details
    query_params = { q: :connect }.merge(id: params[:id])
    institution = Plaid.search_institutions(query_params).first
    if institution.nil?
      render json: { errors: ["No institution with id #{params[:id]}"] }, status: 403
    else
      response = institution.slice('id', 'name', 'fields')
      response['fields'] = response['fields'].map do |field|
        {
          type: field['type'],
          name: field['name'],
          description: field['label']
        }
      end
      render json: response
    end
  end

  def submit_mfa
    @user.mfa_step(params[:mfa_answers])
    render json: user_hash
  rescue => e
    render json: { errors: ['bad'] }, status: 403
  end

  def get_transactions
    transactions = @user.transactions
    render json: user_hash.merge(transactions: transactions)
  end

  def search
    query_params = params.slice(:q, :id).merge(p: 'connect')
    institutions = Plaid.search_institutions(query_params)
    institutions = [institutions] unless institutions.is_a?(Array)
    institutions.each do |institution|
      institution[:logo] = nil
    end
    render json: institutions
  end

  def all_institutions
    render json: Plaid.all_institutions
  end

  private

  def create_user
    options = { login_only: true }.merge(params.slice(:webhook))
    @user = Plaid::User.create(
      :connect,
      params[:service_id],
      params[:credentials][:username],
      params[:credentials][:password],
      options: options
    )
  end

  def update_user
    @user.update(params[:credentials][:username], params[:credentials][:password])
  end

  def set_user
    @user = Plaid::User.load(:connect, params[:access_token]) if params[:access_token].present?
  end

  def user_hash
    if mfa = @user.mfa
      mfa = [mfa] unless mfa.is_a?(Array)
      mfa = mfa.map { |question| { question: question[:message] || question[:question] } }
    end
    accounts = @user.accounts.map { |account| account_hash(account) } if @user.accounts.present?
    {
      access_token: @user.access_token,
      accounts: accounts,
      mfa: mfa
    }
  end

  def account_hash(account)
    type = case account.type
           when :depository
             'bank'
           when :credit
             'credit'
           else
             'other'
           end
    {
      id: account.id,
      name: account.meta['name'],
      number: account.meta['number'],
      type: type,
      available_balance: account.available_balance,
      current_balance: account.current_balance
    }
  end
end
