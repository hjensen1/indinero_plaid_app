module Plaid
  class << self
    def search_institutions(params)
      connector = Connector.new('/institutions/search', client: Plaid.client)
      connector.get(params)
    end

    def all_institutions
      list = []
      results = 1
      offset = 0
      while results.present?
        connector = Connector.new('/institutions/longtail', client: Plaid.client, auth: true)
        results = connector.post(count: 1000, offset: offset)['results']
        list += results
        offset += 1000
      end
      list
    end
  end
end
