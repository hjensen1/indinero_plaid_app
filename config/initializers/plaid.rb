# require 'plaid/connection.rb'
require 'plaid/plaid.rb'

plaid_config = YAML::load(File.open("#{Rails.root}/config/plaid.yml"))[Rails.env]

Plaid.config do |p|
  p.client_id = plaid_config['client_id']
  p.secret = plaid_config['secret']
  p.env = plaid_config['endpoint']
end
