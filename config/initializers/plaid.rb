# require 'plaid/connection.rb'
require 'plaid/plaid.rb'

plaid_config = YAML::load(File.open("#{Rails.root}/config/plaid.yml"))[Rails.env]

Plaid.config do |p|
  p.customer_id = plaid_config['customer_id']
  p.secret = plaid_config['secret']
  p.environment_location = plaid_config['endpoint']
end
